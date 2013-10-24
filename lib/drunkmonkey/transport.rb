require "websocket"

module DrunkMonkey
  module Transport
    # Taken from https://github.com/simulacre/sinatra-websocket/
    # Originally taken from skinny https://github.com/sj26/skinny and updated to support Firefox
    def self.websocket? env
      env['HTTP_CONNECTION'] && env['HTTP_UPGRADE'] &&
        env['HTTP_CONNECTION'].split(',').map(&:strip).map(&:downcase).include?('upgrade') &&
        env['HTTP_UPGRADE'].downcase == 'websocket'
    end
    
    def self.connection_from env, options
      request = Rack::Request.new(env)
      if websocket? env
        WebSocket.resume request, **options
        [500,{},[]]
      else
        body = Comet.resume request, **options
        [200,{},[body]]
      end
    end
    
    class Base
      class << self
        def resume request, **options
          @sessions ||= {}
        
          params = parse_params request
          id = request.post? ? params["socket"] : params["id"]
        
          session = @sessions[id]
        
          return session if session
          @sessions[id] = new **options
        end
      
        def parse_params request
          if request.post?
            input = request.env["rack.input"]
            input.rewind
            parameters = input.read.sub(/\Adata=/,"")
            input.rewind
            params = JSON.parse(parameters)
          else
            params = request.params
          end
        end
      end
    
      def initialize **options
        @controller = Celluloid::Actor[options[:controller_name]]
        @messages = []
      end
    
      def portal message
        @i ||= 0
        {type:"message", data:message, id:(@i+=1),reply:false}.to_json
      end
    end
  
    class HijackAPINotFoundError < StandardError;end
    
    class WebSocket < Base
      include Celluloid
    
      def self.resume request, **options
        websocket = super
        websocket.handle_connection request
      end
    
      def handle_connection request
        handshake request
        @controller.async.fire :open, Actor.current
        loop do
          Celluloid.sleep 0.001
          upstream
          downstream
          return if @socket.closed?
        end
      end
    
      def push message
        @messages << message
      end
    
      private
      def handshake request
        env = request.env
        raise HijackAPINotFoundError unless hijack = env["rack.hijack"]
        hijack.call
        @socket = env["rack.hijack_io"]
        @handshake = ::WebSocket::Handshake::Server.new
        @handshake.from_rack env
        @socket.write @handshake.to_s
      end
    
      def upstream
        buffer = ::WebSocket::Frame::Incoming::Server.new(version: @handshake.version)
        buffer << @socket.read_nonblock(1024) rescue nil
        while frame = buffer.next
          case frame.type
          when :text, :binary
            data = JSON.parse(frame.data)
            @controller.async.fire :message, Actor.current, data["data"]
          end
        end
      end
    
      def downstream
        if message = @messages.shift
          @socket.write(
            ::WebSocket::Frame::Outgoing::Server.new(
              data: portal(message), type: :text, version: @handshake.version))
        end
      rescue Errno::EPIPE => e  
      end
    end
    
    class Comet < Base
      include Celluloid

      def self.resume request, **options
        comet = super
        comet.handle_connection(request)
      end

      def handle_connection request
        params = self.class.parse_params(request)
        request.post? ? upstream(params) : downstream(params)
      end

      def push message
        @messages << message
        signal :pushed
      end

      private
      def upstream params
        @controller.async.fire :message, Actor.current, params["data"]
        ""
      end

      def downstream params
        if params["when"] == "open"
          @controller.async.fire :open, Actor.current
          ""
        else
          wait :pushed if @messages.empty?
          message = @messages.shift
          message ? portal(message) : ""
        end
      end
    end
  
  end
end