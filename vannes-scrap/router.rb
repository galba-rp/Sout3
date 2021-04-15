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
        if url.include?("simply-home-cda") 
          res = controller.getHouseInfoAuray(url)
          [200, {"Content-Type" => "application/json", "Access-Control-Allow-Origin" => "*"}, [res.to_json]]
        elsif  url.include?("simply-home-group")
          res = controller.getHouseInfoQuestembert(url)
         
          [200, {"Content-Type" => "application/json", "Access-Control-Allow-Origin" => "*"}, [res.to_json]]
        else
          res = controller.getHouseInfoVannes(url) 
          [200, {"Content-Type" => "application/json", "Access-Control-Allow-Origin" => "*"}, [res.to_json]]
     
        end 

     else
        # controller.not_found
     end
  end
end