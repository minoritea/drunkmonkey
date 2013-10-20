# DrunkMonkey

DrunkMonkey is a rack middleware providing realtime two-way http communication with API for [portal.js](https://github.com/flowersinthesand/portal/ "Portal").


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
  use DrunkMonkey::Builder do
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

use DrunkMonkey::Builder do
  on :message do |socket, message|
    socket.push "ECHO: #{message}"
  end
end
```
Note: the class passed **use** method is initialized with the block for each requests, so handlers are reset everytime. 

Then, include Portal to HTML and initialize it as follows.

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


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request