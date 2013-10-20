require "puma"
require "rack/handler/puma"
$:.unshift File.expand_path("./lib")
require "drunkmonkey"

list = []
Rack::Handler::Puma.run(Rack::Builder.new{
  root = File.dirname(__FILE__)
  use DrunkMonkey::Builder do
    on :open do |socket|
      socket.push "Welcome!"
    end
    
    on :message do |socket,msg|
      if match = msg.match(/\AI am (.+)/)
        list << match[1]
        socket.push "Current members are #{list.join(',')}"
      end
    end
  end
  
  use Rack::Static, urls:[""], index:"index.html", root:"#{root}/public"
  run -> env { [404, {'Content-Type' => 'text/html'}, ['Not Found']] }
})