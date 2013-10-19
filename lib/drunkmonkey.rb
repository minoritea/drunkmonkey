require "drunkmonkey/version"
require "celluloid"
require "rack"
require "celluloid/autostart"
require "forwardable"
require "json"
require "drunkmonkey/transport"

module DrunkMonkey
  class Controller
    include Celluloid
    def initialize name = :default_controller
      @handlers = Hash.new
      Actor[name] = Actor.current
    end

    def on event, &block
      @handlers[event] ||= block
    end
    
    execute_block_on_receiver :on

    def fire event, transport, message = nil
      handler = @handlers[event]
      handler.call transport, message if handler
    end
  end
  
  class Builder < ::Rack::Builder
    extend Forwardable
    
    DEFAULT_OPTIONS = {
      enable_session: true,
      path: "/hijacker",
      session_secret: "secret#{object_id}",
      session_key: "rack.hijacker.session",
      controller_name: :default_controller
    }.freeze
    
    def_delegator :controller, :on
    
    def controller
      self.class.controller
    end
    
    def controller= instance
      self.class.controller=instance
    end
    
    class << self
      attr_accessor :controller
    end
    
    def initialize default_app = nil, **options , &block
      options = DEFAULT_OPTIONS.merge(options)
      self.controller ||= Controller.new(options[:controller_name])
      
      super(default_app, &block)
      
      map options[:path] do
        run -> env do
          Transport.connection_from env, options
        end
      end  
    end
    

    
  end
end