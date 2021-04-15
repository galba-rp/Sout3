require "nokogiri"
require "open-uri"
require "pry"
require "sqlite3"
require "./lib/house-sanit"

@db = SQLite3::Database.new("boardimo.db")
i = 1

links = ["questembert", "maison_vannes_", "sene"]


  while i < 6 do
    links.each { |j|
      url = "https://simply-home-group.herokuapp.com/#{j}#{i}.php"
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
    @db.execute("INSERT OR IGNORE INTO property VALUES (:id, :title, :cityName, :postCode, :price, :surface, :energy, :year, :url, :img, :fee)", sanitized_data) 
  }
  i += 1
  end
