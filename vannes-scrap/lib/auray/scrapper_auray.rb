require "nokogiri"
require "open-uri"
require "pry"
require "sqlite3"
require "./lib/house-sanit"
class ScrapperAuray

  @db = SQLite3::Database.new("boardimo1.db")
  
  url = "https://simply-home-cda.herokuapp.com/pages/nosmaisons.php"
  html = URI.open(url)
  app = Nokogiri::HTML(html)
  href = app.css(".card a")
  
  href.each { |a| 
 
    url = "https://simply-home-cda.herokuapp.com/pages/" + a.attributes['href'].value
    html = URI.open(url)
    app = Nokogiri::HTML(html)
    surface = app.css("#single-ad-description p")[0].text
    city = app.css("#single-ad-description p")[1].text
    price = app.css("#single-ad-description p")[2].text
    energy = app.css("#single-ad-description p")[3].text
    year = app.css("#single-ad-description p")[4].text
    img = app.css("#secion-ad img").first.attr("src")
    fee = app.css("#single-ad-description p")[6].text
    title = app.css("h1").text

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