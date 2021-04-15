require "nokogiri"
require "open-uri"
require "pry"
require "sqlite3"
require "./lib/house-sanit"

class ScrappeurQuestembert

  @db = SQLite3::Database.new("boardimo1.db")

  url = "https://simply-home-group.herokuapp.com/NosMaisons.php"
  html = URI.open(url)
  app = Nokogiri::HTML(html)
  href = app.css(".card")
  

  href.each { |a| 

        url = "https://simply-home-group.herokuapp.com/" + a.attributes['href'].value
        html = URI.open(url)
        app = Nokogiri::HTML(html)
        surface = app.css(".surface").text
        city = app.css(".city").text
        price = app.css(".price").text
        energy = app.css(".energetic").text
        year = app.css(".year").text
        img = app.css(".houseImg img").first.attr("src")
        fee = app.css(".fees").text
        title = app.css(".title").text

      sanitized_data = 
          HouseSanitizer.new(
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
          @db.execute("INSERT OR IGNORE INTO city VALUES (:city_name)", sanitized_data[:cityName])
          @db.execute("INSERT OR IGNORE INTO property VALUES ( :id, :title, :postCode, :price,  :surface, :energy, :year, :url, :img, :fee, :cityName)", sanitized_data)
    
    
  }
end
