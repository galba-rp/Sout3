require "tilt"
require "erb"
require 'json'
require './lib/controller'


require "pry"


class Router

  def controller
    @controller ||= Controller.new
  end

  
  
  
  def call(env)
    path = env["REQUEST_PATH"]
    req = Rack::Request.new(env)
    body = req.body
    url = JSON.parse(body.string)["url"]
    
    
    # params = {}

    # params.merge!(body ? JSON.parse(body) : {})

     controller

     case path
       when "/get-info"
        # [200, {"Content-Type" => "application/json", "Access-Control-Allow-Origin" => "*"}, {boy: "answer"}]
        if url.include?("simply-home-cda") 
          [200, {"Content-Type" => "application/json", "Access-Control-Allow-Origin" => "*"}, {boy: "answer"}]
        elsif  url.include?("simply-home-groupe")
          [200, {"Content-Type" => "application/json", "Access-Control-Allow-Origin" => "*"}, {boy: "answer"}]
        else
          res = controller.getHouseInfoVannes(url)
          [200, {"Content-Type" => "application/json", "Access-Control-Allow-Origin" => "*"}, [res]]
     
        end 

     else
        # controller.not_found
     end
  end
end