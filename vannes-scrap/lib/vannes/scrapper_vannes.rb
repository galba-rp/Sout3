require "nokogiri"
require "open-uri"
require "pry"
require "sqlite3"

require "./lib/house-sanit"



@db = SQLite3::Database.new("boardimo.db")
i = 1

while i < 16 do

  url = "https://simply-home.herokuapp.com/house#{i}.php"
  html = URI.open(url)
  app = Nokogiri::HTML(html)
  surface = app.css(".size").text
  city = app.css(".location").text
  price = app.css(".price").text
  energy = app.css(".energy").text
  year = app.css(".foundation-years").text
  img = app.css("#singleArticleImage img").attr("src").value
  title = app.css("#titleSingleArticle h2").text
  fee = app.css("#articleSubContent").text

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
 i += 1
end