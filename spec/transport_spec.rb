require "spec_helper"
require "drunkmonkey"

module Helpers
  def websocket_env
    env = Hash.new
    env['HTTP_CONNECTION'] = "UPGRADE"
    env['HTTP_UPGRADE']    = "WEBSOCKET"
    env
  end
end

RSpec.configure do |c|
  c.include Helpers
end

module DrunkMonkey
  describe Transport do
    describe ".websocket?" do
      specify do
        env = websocket_env
        expect(Transport.websocket?(env)).to eq(true)
      end
      specify do
        env = Hash.new
        env['HTTP_CONNECTION'] = ""
        env['HTTP_UPGRADE']    = ""
        expect(Transport.websocket?(env)).to eq(false)
      end
    end
  end
  
  module Transport
    describe Base do
      describe "#initialize" do
        specify do
          base = Base.new controller_name: :controller
          expect(base.instance_variable_get(:@messages)).to eq([])
        end
      end
      
      describe "#portal" do
        specify do
          base = Base.new controller_name: :controller
          expect(base.portal("hello")).to eq({type:"message", data:"hello", id:1,reply:false}.to_json)
        end
      end
      
      describe ".parse_params" do
        specify do
          env = websocket_env
          env["REQUEST_METHOD"] = "POST"
          env["rack.input"] = StringIO.new(%(data={"data":"aaa"}))
          expect(Base.parse_params(Rack::Request.new(env))).to eq({"data" => "aaa"})
        end
        
        specify do
          env = websocket_env
          env["REQUEST_METHOD"] = "GET"
          env["rack.input"] = StringIO.new("")
          env["QUERY_STRING"] = "data=aaa"
          expect(Base.parse_params(Rack::Request.new(env))).to eq({"data" => "aaa"})
        end
      end
      
      describe ".resume" do
        specify do
          env = websocket_env
          env["REQUEST_METHOD"] = "GET"
          env["rack.input"] = StringIO.new("")
          env["QUERY_STRING"] = "id=111"
          session = Base.resume(Rack::Request.new(env), controller_name: :default_controller)
          expect(Base.resume(Rack::Request.new(env),
            controller_name: :default_controller)).to eq(session)
        end
        
        specify do
          env = websocket_env
          env["REQUEST_METHOD"] = "POST"
          env["rack.input"] = StringIO.new(%(data={"id":"1234"}))
          session = Base.resume(Rack::Request.new(env), controller_name: :default_controller)
          expect(Base.resume(Rack::Request.new(env),
            controller_name: :default_controller)).to eq(session)
        end
      end
    end
    
    describe WebSocket do
      describe "#push" do
        specify do
          websocket = WebSocket.new(controller_name: :default_controller)
          websocket.push "aaa"
          expect(websocket.instance_variable_get(:@messages)).to eq(["aaa"])
        end
      end
    end
    
    describe Comet do
      describe "#push" do
        specify do
          comet = Comet.new(controller_name: :default_controller)
          comet.push "aaa"
          expect(comet.instance_variable_get(:@messages)).to eq(["aaa"])
        end
      end
    end
  end
end