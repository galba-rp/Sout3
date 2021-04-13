require "rack"
require "thin"
#(re)load
load "router.rb"



handler = Rack::Handler::Thin
handler.run(
  Router.new,
  Port: 7373
)

