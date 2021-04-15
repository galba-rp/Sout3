require "pry"


class HouseSanitizer

  def initialize(data)
    @data = data
    @logger = []
  end 

  
  # # checking unit of area and raising an error if not "m²"
  #   def surface_validatio
  #   unless @data[:surfase].include?("m")
  #     @logger << ""
  # end

  def to_h
    @data.each { |name, value|   
       if !value.nil?  && !value.include?('http') && value.include?(':') 
        @data[name] = value.split(':').last
       end
    }

    begin
      
      cleanSurface
      cleanPrice
      cleanCityName
      cleanPostcode
      cleanYear
      cleanEnergy
      cleanImage
      cleanTitle
      cleanFee
      @data.delete(:city)
      @data
    rescue => error
      @logger << error.message
      {}
    end
  end

  private

  def cleanSurface
    @data[:surface].downcase!
    if @data[:surface].include?("m")
      @data[:surface] = @data[:surface].split("m").first.tr(' ','').to_i
    else 
      @data[:surface] = @data[:surface].tr(' ','').to_i
    end

  end

  def cleanPrice
    if @data[:price].include?("€")
      @data[:price] = @data[:price].split("€").first.tr(' ','').to_i
    else
      @data[:price] = @data[:price].tr(' ','').to_i
    end

  end

  

  # checking if post code is included in the city string
  # separating name from post code nad cleaning name
  def cleanCityName
    unless @data[:city].count("^0-9").zero?
      @data[:cityName] = @data[:city].tr("0-9", '').strip.capitalize
    else
      @data[:cityName] = @data[:city].strip.capitalize
    end
  end

  # cleanPostcode will be 0 if postcode is not included in city name string
  def cleanPostcode
    unless @data[:city].count("^0-9").zero?
      @data[:postCode] = @data[:city].tr("^0-9", '').to_i
    else
      data[:postCode] = 0
    end
  end

  def cleanYear
    @data[:year] = @data[:year].strip.to_i
  end

  def cleanEnergy
    @data[:energy] = @data[:energy].strip.upcase
  end

  def cleanImage
    case 
      when @data[:url].include?("simply-home-cda")
        @data[:img] = "https://simply-home-cda.herokuapp.com/" + @data[:img]
      when @data[:url].include?("simply-home-group")
        @data[:img] = "https://simply-home-group.herokuapp.com/" + @data[:img]
      else 
        @data[:img] = "https://simply-home.herokuapp.com//" + @data[:img]
      end
  end

  def cleanTitle
    @data[:title] = @data[:title].strip.capitalize
  end

  def cleanFee
   if @data[:fee].include?("[no]") 
    @data[:fee] = 0
   else 
    @data[:fee] = 1
   end
  
  end
end