require "httparty"
require "json"

# Converts an address into latitude and longitude coordinates
# using the geocode.maps.co API.
class GeocodeService
  def self.geocode(address_params)
    response = HTTParty.get("https://geocode.maps.co/search",
      query: {
        street: address_params[:street],
        city: address_params[:city],
        state: address_params[:state],
        postalcode: address_params[:postal_code],
        country: address_params[:country],
        limit: 1,
        api_key: ENV["GEOCODE_API_KEY"]
      })

    if response.code == 200
      # Use the most relevant result
      data = JSON.parse(response.body)[0]
      {
        lat: data["lat"],
        lon: data["lon"]
      }
    else
      raise GeocodingError, "Geocode Request Failed"
    end
  end
end