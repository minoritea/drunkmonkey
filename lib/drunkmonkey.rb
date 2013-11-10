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
      @handlers[event] = block
    end
    
    execute_block_on_receiver :on

    def fire event, transport, message = nil
      handler = @handlers[event]
      handler.call transport, message if handler
    end
  end
  
  class Base
    extend Forwardable
    
    DEFAULT_OPTIONS = {
      path: "/drunkmonkey",
      controller_name: :default_controller
    }.freeze
    
    def_delegator :@controller, :on
    def_delegator :@map, :call
    
    def initialize app = nil, options = {}, &block
      options = DEFAULT_OPTIONS.merge(options)
      @controller = Celluloid::Actor[options[:controller_name]] ||
        Controller.new(options[:controller_name])
      
      instance_eval(&block) if block
      
      mapping = Hash.new
      mapping[options[:path]] = -> env do
        Transport.call env, options
      end
      
      @base_mapping = mapping.dup
      
      mapping["/"] = app if app
      
      @map = Rack::URLMap.new mapping
    end
    
    def remap app = nil
      mapping = @base_mapping.dup
      mapping["/"] = app if app
      @map = Rack::URLMap.new mapping
    end
    
    def self.middleware
      Class.new do
        class << self
          attr_accessor :base
        end
        
        def initialize app = nil, options = {}, &block
          if self.class.base
            self.class.base.remap app
          else
            self.class.base = Base.new(app,options,&block)
          end
        end
      
        def call env
          self.class.base.call env
        end
      end
    end
  end
  
  Middleware = Base.middleware
end