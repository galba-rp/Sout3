class SingleHouse

  # def initialize(url)
  #   @url = url
  # end

  html = URI.open(@url)
  app = Nokogiri::HTML(html)
  surface = app.css(".size").text
  city = app.css(".location").text
  price = app.css(".price").text
  energy = app.css(".energy").text
  year = app.css(".foundation-years").text

  sanitized_data = 
    HouseSanitizer.new(
      city: city,
      price: price,
      surface: surface,
      energy: energy,
      cityName: "",
      postCode: 0,
      year: year,
      url: url
    ).to_h
    binding.pry
end