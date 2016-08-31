require "uri"
require "stringio"

module FedexSMS
  class Client
    DEFAULT_CONNECT_TIMEOUT = 1.0
    DEFAULT_READ_TIMEOUT = 10.0
    DEFAULT_PORT = 2000

    class ConnectionError < IOError
    end

    attr_accessor :host, :port, :connect_timeout, :read_timeout

    def initialize(host,
      port: DEFAULT_PORT,
      connect_timeout: DEFAULT_CONNECT_TIMEOUT,
      read_timeout: DEFAULT_READ_TIMEOUT)

      self.host = host
      self.port = port
      self.connect_timeout = connect_timeout
      self.read_timeout = read_timeout
    end

    def post_transactions(transactions)
      open do |socket|
        responses = transactions.map do |transaction|
          socket.write(transaction.to_s)
          socket.write("\0")
          read_response(socket)
        end

        responses.map(&Transaction.method(:load))
      end
    end

    private

      def open
        begin
          socket = connect
        rescue Errno::ECONNREFUSED
          raise ConnectionError, "FedEx SMS refused to establish a connection."
        rescue Errno::ETIMEDOUT
          raise ConnectionError, "The connection to the FedEx SMS timed out."
        rescue
          raise ConnectionError, "Unable to establish a connection to FedEx SMS."
        end

        yield(socket)
      ensure
        socket.close if socket
      end

      def connect
        addr = Socket.getaddrinfo(host, nil)
        sockaddr = Socket.pack_sockaddr_in(port, addr[0][3])
        socket = Socket.new(Socket.const_get(addr[0][0]), Socket::SOCK_STREAM, 0)
        socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
        socket.connect_nonblock(sockaddr)
        socket
      rescue IO::WaitWritable
        raise Errno::ETIMEDOUT if IO.select(nil, [socket], nil, connect_timeout).nil?

        begin
          socket.connect_nonblock(sockaddr)
        rescue Errno::EISCONN
        end

        socket
      end

      def read_response(socket)
        buf = ""

        loop do
          begin
            read = socket.recv_nonblock(1024)
          rescue IO::WaitReadable
            retry if IO.select([socket], nil, nil, read_timeout)
            raise ConnectionError, "FedEx SMS timed out while reading."
          end

          buf << read
          break if read.end_with?("\0")
        end

        buf
      end
  end
end
