require "spec_helper"
require "drunkmonkey"

module DrunkMonkey
  describe Base do
    describe "DEFAULT_OPTIONS" do
      specify do
        option = {
          path: "/drunkmonkey",
          controller_name: :default_controller
        }
        expect(Base::DEFAULT_OPTIONS).to eq(option)
      end
    end
    
    describe "@controller" do
      specify do
        base = Base.new
        expect(base.instance_variable_get(:@controller)).to eq(Celluloid::Actor[:default_controller])
      end
    end
    
    describe "#on" do
      specify do
        base = Base.new controller_name: :default_controller
        handler = proc{|socket,message|  }
        base.on :message, &handler
        controller = Celluloid::Actor[:default_controller]
        expect(controller.instance_variable_get(:@handlers)[:message]).to eq(handler)
      end
    end
  end
  
  describe Middleware do
    describe "#initialize" do
      specify do
        app = -> env {[200,{},[]]}
        middleware = Middleware.new(app,{}){}
        expect(Middleware.new(app,{}){}.class.base).to eq(middleware.class.base)
      end
    end
    
    describe "#call" do
      specify do
        app = -> env {[200,{},[env]]}
        middleware = Middleware.new(app,{}){}
        env = {
          "REQUEST_METHOD" => "GET",
          "SCRIPT_NAME" => "",
          "PATH_INFO" => "/",
          "QUERY_STRING" => "",
          "SERVER_NAME" => "localhost",
          "SERVER_PORT" => "80",
          "rack.input" => StringIO.new("")
          
        }
        
        expect(middleware.call(env)).to eq(Middleware.base.call(env))
      end
    end
  end
end