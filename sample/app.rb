require "puma"
require "rack/handler/puma"
$:.unshift File.expand_path("./lib")
require "drunkmonkey"

sockets = {}
Rack::Handler::Puma.run(Rack::Builder.new{
  root = File.dirname(__FILE__)
  use DrunkMonkey::Middleware do
    on :open do |socket|
      sockets[socket] = ""
    end
    
    on :message do |socket,msg|
      if sockets[socket].empty?
        sockets[socket] = msg
        socket.push "Welcome, #{msg}!"
      else
        name = sockets[socket]
        sockets.each{|s,_|s.push "#{name}: #{msg}"}
      end
    end
  end
  
  use Rack::Static, urls:[""], index:"index.html", root:"#{root}/public"
  run -> env { [404, {'Content-Type' => 'text/html'}, ['Not Found']] }
})