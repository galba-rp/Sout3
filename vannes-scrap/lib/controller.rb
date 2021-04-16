require "tilt"
require "erb"
require "./lib/house-sanit"
require "nokogiri"
require "open-uri"
require "sqlite3"
require "./lib/colors"


require "pry"

class Controller


  @sanitized_data
  @price_square_meter = 0
  @energy_cost = 0
  @avg_square_meter = 0
 
  @city = ""
  @price = 0
  @surface = 0
  @energy = ""
  @year = 0
  @url = ""
  @img = ""
  @title = ""
  @fee = 0

  def initialize
    @db = SQLite3::Database.new("boardimo.db")
  end

  def get_sanitized_data
    
   sanitized_data =  HouseSanitizer.new(
      city: @city,
      price: @price,
      surface: @surface,
      energy: @energy,
      cityName: "",
      postCode: "",
      year: @year,
      url: @url,
      img: @img,
      title: @title,
      fee: @fee
    )
    sanitized_data 
  end

  def get_app(url)
    @url = url
    html = URI.open(url)
    app = Nokogiri::HTML(html)
  end

  # TODO create color constants
  def average_year
    total_houses = @db.execute("SELECT COUNT(year) FROM property WHERE  cityName='#{@sanitized_data[:cityName]}'")
    older_then_this_house = @db.execute("SELECT COUNT(year) FROM property WHERE year<#{@sanitized_data[:year]}  AND cityName='#{@sanitized_data[:cityName]}'")
    avg_year = @db.execute("SELECT AVG(year) FROM property WHERE year > 1 AND cityName='#{@sanitized_data[:cityName]}'")
    
    more_recent = older_then_this_house[0][0]*100/total_houses[0][0]
    @year = @sanitized_data[:year]
    year_today = Time.now.year
    case
    when @year + 10 > year_today
      year_color = Colors::GREEN
    when @year + 20 > year_today
      year_color = Colors::YELLOW
    when @year + 40 > year_today
      year_color = Colors::ORANGE
    else
      year_color = Colors::RED
  end
    @sanitized_data[:yearColor] = year_color
    @sanitized_data[:moreRecentPercent] = more_recent.to_i
    @sanitized_data[:avgYear] = (@sanitized_data[:year] - avg_year[0][0]).to_i
  end

  def average_renov
    surface= @sanitized_data[:surface]
    @sanitized_data[:renovCost] = @sanitized_data[:surface] *  345
    case @sanitized_data[:yearColor]
      when Colors::GREEN
        @sanitized_data[:renovSaving] = surface * -245
      when Colors::YELLOW
        @sanitized_data[:renovSaving] = surface * -105
      when Colors::ORANGE
        @sanitized_data[:renovSaving] = surface * 95
      else
        @sanitized_data[:renovSaving] = surface * 355
      end
  end

  def average_price
    avg_price = @db.execute("SELECT AVG(price) FROM property WHERE cityName='#{@sanitized_data[:cityName]}'")
    avg_area = @db.execute("SELECT AVG(surface) FROM property WHERE cityName='#{@sanitized_data[:cityName]}'")
    @avg_square_meter = avg_price[0][0]/avg_area[0][0]
   
    @price_square_meter = @sanitized_data[:price]/@sanitized_data[:surface]
    case
      when @price_square_meter < @avg_square_meter*0.75 
        color = Colors::GREEN
      when @price_square_meter >= @avg_square_meter*0.75 && @price_square_meter < @avg_square_meter*1.25
        color = Colors::YELLOW
      when @price_square_meter < @avg_square_meter*1.5 && @price_square_meter >= @avg_square_meter*1.25
        color = Colors::ORANGE
      else
        color = Colors::RED
    end
    difference = (@avg_square_meter-@price_square_meter)*100/@avg_square_meter
    @sanitized_data[:priceColor] = color
    @sanitized_data[:avgPrice] = @avg_square_meter.to_i
    @sanitized_data[:difference] = difference.to_i.abs
  end

  def average_energy
    energy = @sanitized_data[:energy]
    total_houses = @db.execute("SELECT COUNT(title) FROM property WHERE  cityName='#{@sanitized_data[:cityName]}'")
    houses_better_energy = @db.execute("SELECT COUNT(title) FROM property WHERE energy <'#{@sanitized_data[:energy]}'  AND cityName='#{@sanitized_data[:cityName]}'")
    
    case energy
      when "A"
        color = Colors::GREEN
        @energy_cost = -216.6
      when "B"
        color = Colors::GREEN
        @energy_cost = -161.5
      when "C" 
        color = Colors::YELLOW
        @energy_cost = -81.7
      when "D" 
        color = Colors::YELLOW
        @energy_cost = 30.4
      when "E"
        color = Colors::ORANGE
        @energy_cost = 76
      when "F"
        color = Colors::RED
        @energy_cost = 188.1
      else
        color = Colors::RED
        @energy_cost = 340
    end

    @sanitized_data[:energyColor] = color
    @sanitized_data[:energyCost] = @energy_cost
    @sanitized_data[:energyPercent] = houses_better_energy[0][0]*100/total_houses[0][0]
  end

  def estimation
    renov_cost_sq_m = @sanitized_data[:renovSaving]/@sanitized_data[:surface]
    real_price_sq_m = @price_square_meter + @energy_cost + renov_cost_sq_m
    @sanitized_data[:realPriceSqM] = real_price_sq_m 

    case
      when real_price_sq_m < @avg_square_meter
        estim_color = Colors::GREEN
      when real_price_sq_m >= @avg_square_meter && real_price_sq_m < @avg_square_meter*1.1
        estim_color = Colors::YELLOW
      when real_price_sq_m >= @avg_square_meter*1.1 && real_price_sq_m < @avg_square_meter*1.25
        estim_color = Colors::ORANGE
      else
        estim_color = Colors::RED
    end
    @sanitized_data[:estimColor] = estim_color
    @sanitized_data[:priceRangeLow] = (@avg_square_meter*0.9*@sanitized_data[:surface]/1000).to_i
    @sanitized_data[:priceRangeHigh] = (@avg_square_meter*1.1*@sanitized_data[:surface]/1000).to_i
  end

  def get_analytics
    average_price
    average_year
    average_renov
    average_energy
    estimation
  end

  def get_house_info_vannes(url)
    
    app = get_app(url)
    @surface = app.css(".size").text
    @city = app.css(".location").text
    @price = app.css(".price").text
    @energy = app.css(".energy").text
    @year = app.css(".foundation-years").text
    @img = app.css("#singleArticleImage img").attr("src").value
    @title = app.css("#titleSingleArticle h2").text
    @fee = app.css("#articleSubContent").text
   
   

    @sanitized_data =  get_sanitized_data.to_h
    get_analytics
   @sanitized_data
  end

  def get_house_info_auray(url)
      app = get_app(url)
      @surface = app.css("#single-ad-description p")[0].text
      @city = app.css("#single-ad-description p")[1].text
      @price = app.css("#single-ad-description p")[2].text
      @energy = app.css("#single-ad-description p")[3].text
      @year = app.css("#single-ad-description p")[4].text
      @img = app.css("#secion-ad img").first.attr("src")
      @fee = app.css("#single-ad-description p")[6].text
      @title = app.css("h1").text

      @sanitized_data =  get_sanitized_data.to_h
   
      get_analytics
      @sanitized_data
    end

    def get_house_info_questembert(url)
     
        app = get_app(url)
        @surface = app.css(".surface").text
        @city = app.css(".city").text
        @price = app.css(".price").text
        @energy = app.css(".energetic").text
        @year = app.css(".year").text
        @img = app.css(".houseImg img").first.attr("src")
        @fee = app.css(".fees").text
        @title = app.css(".title").text

        @sanitized_data =  get_sanitized_data.to_h
        get_analytics
        @sanitized_data
    end
end