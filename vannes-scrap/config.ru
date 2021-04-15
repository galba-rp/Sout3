require "rack/cors"
require "rack"
require "thin"

#(re)load
load "router.rb"




handler = Rack::Handler::Thin

use Rack::Cors do
  allow do
    origins '*'

    resource '*', 
      headers: :any, 
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end

handler.run(
  Router.new,
  Port: 7373
)

