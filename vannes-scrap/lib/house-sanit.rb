require "pry"


class HouseSanitizer

  def initialize(data)
    @data = data
    @logger = []
  end 

  # checking if price is less then 10 000 for mistakes or cases of "100k" and raising an error if not "m²"
  def price_validation
    unless @data[:price] > 150000
      @logger << "RangeError: Value of [#{@data[:price]}] is less then 10 000"

      raise RangeError
    end
  end

   # checking if postcode has 5 numbers and length is 5"
   def postecode_validation
    unless @data[:posteCode].length  == 5 || @data[:posteCode].count("0-9") == 5
      @logger << "RangeError: Value of [#{@data[:price]}] has to contain exactly 5 digits"

      raise RangeError
    end
  end

  # checking if year is within  1000 and current year"
  def year_validation
    current_year = Time.new.year
    if @data[:year].to_i .between?(1000, current_year)
      @logger << "RangeError: Value of [#{@data[:year]}] is outside of range  [1000, #{current_year}]"

      raise RangeError
    end
  end

  def to_h
    @data.each { |name, value|   
       if !value.nil?  && !value.include?('http') && value.include?(':') 
        @data[name] = value.split(':').last
       end
    }

   def validations
    price_validation
    postecode_validation
    year_validation
   end
   
  begin
      clean_surface
      clean_price
      clean_city_name
      clean_postcode
      clean_year
      clean_energy
      clean_image
      clean_title
      clean_fee
      @data.delete(:city)
      @data

    rescue => error
      @logger << error.message
      {}
    end
  end
  
  private

  def clean_surface
    @data[:surface].downcase!
    if @data[:surface].include?("m")
      @data[:surface] = @data[:surface].split("m").first.tr(' ','').to_i
    else 
      @data[:surface] = @data[:surface].tr(' ','').to_i
    end
  end

  def clean_price
    if @data[:price].include?("€")
      @data[:price] = @data[:price].split("€").first.tr(' ','').to_i
    else
      @data[:price] = @data[:price].tr(' ','').to_i
    end
  end

  # checking if post code is included in the city string
  # separating name from post code nad cleaning name
  def clean_city_name
    unless @data[:city].count("^0-9").zero?
      @data[:cityName] = @data[:city].tr("0-9", '').strip.capitalize
    else
      @data[:cityName] = @data[:city].strip.capitalize
    end
  end

  # clean_postcode will be 0 if postcode is not included in city name string
  def clean_postcode
    unless @data[:city].count("^0-9").zero?
      @data[:postCode] = @data[:city].tr("^0-9", '').to_i
    else
      data[:postCode] = 0
    end
  end

  def clean_year
    @data[:year] = @data[:year].strip.to_i
  end

  def clean_energy
    @data[:energy] = @data[:energy].strip.upcase
  end

  def clean_image
    case 
      when @data[:url].include?("simply-home-cda")
        @data[:img] = "https://simply-home-cda.herokuapp.com/" + @data[:img]
      when @data[:url].include?("simply-home-group")
        @data[:img] = "https://simply-home-group.herokuapp.com/" + @data[:img]
      else 
        @data[:img] = "https://simply-home.herokuapp.com//" + @data[:img]
      end
  end

  def clean_title
    @data[:title] = @data[:title].strip.capitalize
  end

  def clean_fee
   if @data[:fee].include?("[no]") 
    @data[:fee] = 0
   else 
    @data[:fee] = 1
   end
  end
end