require "tilt"
require "erb"
require 'json'
require "pry"

require './lib/controller'

class Router

  def controller
    @controller ||= Controller.new
  end
  
  def call(env)
    path = env["REQUEST_PATH"]
    req = Rack::Request.new(env)
    body = req.body
    url = JSON.parse(body.string)["url"]

     case path
       when "/get-info"
        if url.include?("simply-home-cda") 
          res = controller.get_house_info_auray(url)
          [200, {"Content-Type" => "application/json", "Access-Control-Allow-Origin" => "*"}, [res.to_json]]
        elsif  url.include?("simply-home-group")
          res = controller.get_house_info_questembert(url)
          [200, {"Content-Type" => "application/json", "Access-Control-Allow-Origin" => "*"}, [res.to_json]]
        else
          res = controller.get_house_info_vannes(url) 
          [200, {"Content-Type" => "application/json", "Access-Control-Allow-Origin" => "*"}, [res.to_json]]
        end 
     else
        # controller.not_found
     end
  end
end