require "tilt"
require "erb"
require "./lib/house-sanit"
require "nokogiri"
require "open-uri"
require "sqlite3"


require "pry"

class Controller

## create m² price variable
  @sanitized_data
  @priceSqM = 0
  @energyCost = 0
  @avgSqM = 0
 
  def initialize
    @db = SQLite3::Database.new("boardimo.db")

  end

  # def getSanitizedData
  #   HouseSanitizer.new(
  #     city: city,
  #     price: price,
  #     surface: surface,
  #     energy: energy,
  #     cityName: "",
  #     postCode: "",
  #     year: year,
  #     url: url,
  #     img: img,
  #     title: title,
  #     fee: fee
  #   ).to_h
  # end

  def getApp(url)
    html = URI.open(url)
    app = Nokogiri::HTML(html)
  end

  # TODO create color constants
  def averageYear
    totalHouses = @db.execute("SELECT COUNT(year) FROM property WHERE  cityName='#{@sanitized_data[:cityName]}'")
    olderThenThisHouse = @db.execute("SELECT COUNT(year) FROM property WHERE year<#{@sanitized_data[:year]}  AND cityName='#{@sanitized_data[:cityName]}'")
    avgYear = @db.execute("SELECT AVG(year) FROM property WHERE year > 1 AND cityName='#{@sanitized_data[:cityName]}'")
    
    moreRecent = olderThenThisHouse[0][0]*100/totalHouses[0][0]
    year = @sanitized_data[:year]
    yearToday = Time.now.year
    case
    when year + 10 > yearToday
      yearColor = 'GreenYellow'
    when year + 20 > yearToday
      yearColor = 'yellow'
    when year + 40 > yearToday
      yearColor = 'orange'
    else
      yearColor = 'Salmon'
  end
    @sanitized_data[:yearColor] = yearColor
    @sanitized_data[:moreRecentPercent] = moreRecent.to_i
    @sanitized_data[:avgYear] = (@sanitized_data[:year] - avgYear[0][0]).to_i
  end

  def averageRenov
    surface= @sanitized_data[:surface]
    @sanitized_data[:renovCost] = @sanitized_data[:surface] *  345
    case @sanitized_data[:yearColor]
      when 'GreenYellow'
        @sanitized_data[:renovSaving] = surface * -245
      when 'yellow'
        @sanitized_data[:renovSaving] = surface * -105
      when 'orange'
        @sanitized_data[:renovSaving] = surface * 95
      else
        @sanitized_data[:renovSaving] = surface * 355
      end
  end

  def averagePrice
    avgPrice = @db.execute("SELECT AVG(price) FROM property WHERE cityName='#{@sanitized_data[:cityName]}'")
    avgArea = @db.execute("SELECT AVG(surface) FROM property WHERE cityName='#{@sanitized_data[:cityName]}'")
    
    @avgSqM = avgPrice[0][0]/avgArea[0][0]
   
    @priceSqM = @sanitized_data[:price]/@sanitized_data[:surface]
    case
      when @priceSqM < @avgSqM*0.75 
        color = 'GreenYellow'
      when @priceSqM >= @avgSqM*0.75 && @priceSqM < @avgSqM*1.25
        color = 'yellow'
       
      when @priceSqM < @avgSqM*1.5 && @priceSqM >= @avgSqM*1.25
        color = 'orange'
      else
        color = 'Salmon'
    end
    difference = (@avgSqM-@priceSqM)*100/@avgSqM
    @sanitized_data[:priceColor] = color
    @sanitized_data[:avgPrice] = @avgSqM.to_i
    @sanitized_data[:difference] = difference.to_i.abs
  end

  def averageEnergy
    energy = @sanitized_data[:energy]
    totalHouses = @db.execute("SELECT COUNT(title) FROM property WHERE  cityName='#{@sanitized_data[:cityName]}'")
    housesBetterEnergy = @db.execute("SELECT COUNT(title) FROM property WHERE energy <'#{@sanitized_data[:energy]}'  AND cityName='#{@sanitized_data[:cityName]}'")
    
    case energy
      when "A"
        color = 'GreenYellow'
        @energyCost = -216.6
      when "B"
        color = 'GreenYellow'
        @energyCost = -161.5
      when "C" 
        color = 'yellow'
        @energyCost = -81.7
      when "D" 
        color = 'yellow'
        @energyCost = 30.4
      when "E"
        color = 'orange'
        @energyCost = 76
      when "F"
        color = 'Salmon'
        @energyCost = 188.1
      else
        color = 'Salmon'
        @energyCost = 340
    end

    @sanitized_data[:energyColor] = color
    @sanitized_data[:energyCost] = @energyCost
    @sanitized_data[:energyPercent] = housesBetterEnergy[0][0]*100/totalHouses[0][0]
  end

  def estimation
    renovCostSqM = @sanitized_data[:renovSaving]/@sanitized_data[:surface]
    realPriceSqM = @priceSqM + @energyCost + renovCostSqM
    @sanitized_data[:realPriceSqM] = realPriceSqM 

    case
      when realPriceSqM < @avgSqM
        estimColor = 'GreenYellow'
      when realPriceSqM >= @avgSqM && realPriceSqM < @avgSqM*1.1
        estimColor = 'yellow'
      when realPriceSqM >= @avgSqM*1.1 && realPriceSqM < @avgSqM*1.25
        estimColor = 'orange'
      else
        estimColor = 'Salmon'
    end
    @sanitized_data[:estimColor] = estimColor
    @sanitized_data[:priceRangeLow] = (@avgSqM*0.9*@sanitized_data[:surface]/1000).to_i
    @sanitized_data[:priceRangeHigh] = (@avgSqM*1.1*@sanitized_data[:surface]/1000).to_i
  end

  def getAnalytics
    averagePrice
    averageYear
    averageRenov
    averageEnergy
    estimation
  end
  def getHouseInfoVannes(url)
    
    app = getApp(url)
    surface = app.css(".size").text
    city = app.css(".location").text
    price = app.css(".price").text
    energy = app.css(".energy").text
    year = app.css(".foundation-years").text
    img = app.css("#singleArticleImage img").attr("src").value
    title = app.css("#titleSingleArticle h2").text
    fee = app.css("#articleSubContent").text
   
   

    @sanitized_data =  HouseSanitizer.new(
      city: city,
      price: price,
      surface: surface,
      energy: energy,
      cityName: "",
      postCode: "",
      year: year,
      url: url,
      img: img,
      title: title,
      fee: fee
    ).to_h
    getAnalytics
   @sanitized_data
  end

  def getHouseInfoAuray(url)
      app = getApp(url)
      surface = app.css("#single-ad-description p")[0].text
      city = app.css("#single-ad-description p")[1].text
      price = app.css("#single-ad-description p")[2].text
      energy = app.css("#single-ad-description p")[3].text
      year = app.css("#single-ad-description p")[4].text
      img = app.css("#secion-ad img").first.attr("src")
      fee = app.css("#single-ad-description p")[6].text
      title = app.css("h1").text
      @sanitized_data =  HouseSanitizer.new(
        city: city,
        price: price,
        surface: surface,
        energy: energy,
        cityName: "",
        postCode: "",
        year: year,
        url: url,
        img: img,
        title: title,
        fee: fee
      ).to_h
   
      getAnalytics
      @sanitized_data
    end

    def getHouseInfoQuestembert(url)
        app = getApp(url)
        surface = app.css(".surface").text
        city = app.css(".city").text
        price = app.css(".price").text
        energy = app.css(".energetic").text
        year = app.css(".year").text
        img = app.css(".houseImg img").first.attr("src")
        fee = app.css(".fees").text
        title = app.css(".title").text
        
        @sanitized_data =  HouseSanitizer.new(
          city: city,
          price: price,
          surface: surface,
          energy: energy,
          cityName: "",
          postCode: "",
          year: year,
          url: url,
          img: img,
          title: title,
          fee: fee
        ).to_h
        getAnalytics
        @sanitized_data
    end
end