# DrunkMonkey

DrunkMonkey is a rack middleware providing realtime two-way http communication with API for [Portal](https://github.com/flowersinthesand/portal/ "Portal").

## Supported servers
You should use servers which supports Rack hijacking API, such as follows:
- Puma

## Installation

Add this line to your application's Gemfile:

    gem 'drunkmonkey'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install drunkmonkey

## Usage

Add DrunkMonkey::Builder to Rack application by **use** method.

Plain Rack:
```ruby
app = Rack::Builder.new do
  use DrunkMonkey::Middleware do
    on :message do |socket, message|
      socket.push "ECHO: #{message}"
    end
  end
end

run app
```

Sinatra:
```ruby
require "sinatra"

use DrunkMonkey::Middleware do
  on :message do |socket, message|
    socket.push "ECHO: #{message}"
  end
end
```
Note: the passed block will be executed once when *use* is called at first.

Then, include [Portal](https://github.com/flowersinthesand/portal/ "Portal") to HTML and initialize it as follows.

```html
<script src="/portal.js"></script>
<script>
/*
 * Following option is a hack to switch protocols automatically
 * when the connection cannot be established.
 */
var options = {
    transports:["ws","longpollajax"],
    reconnect:function(lastDelay,attempts){
      if(options.transports.length > 1)
        options.transports.shift();
      return 2 * (lastDelay || 100);},
    prepare:function(connect,disconnect,opts){
      opts.transports = options.transports;connect();}
};

//Add above options and drunkmonkey's path; default is "/drunkmonkey".
var socket = portal.open("/drunkmonkey",options).on("open",function(){
  //Add you event.
  socket.send("Hello!");
});
</script>
```

Note: in current version, supported transports by Drunkmonkey are websocket and long-poll ajax only.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request