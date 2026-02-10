require "httparty"
require "json"

# Fetches a current and one day weather forecast from the Open Meteo API
# and returns current, maximum, and mininum temperatures for today.
class OpenMeteoService
  def self.retrieve_forecast(coordinates)
    response = HTTParty.get("https://api.open-meteo.com/v1/forecast",
      query: {
        latitude: coordinates[:lat],
        longitude: coordinates[:lon],
        daily: "temperature_2m_max,temperature_2m_min",
        current: "temperature",
        forecast_days: 1
      })

    if response.code == 200
      data = JSON.parse(response.body)
      {
        current_temperature: data["current"]["temperature"],
        maximum_temperature: data["daily"]["temperature_2m_max"][0],
        minimum_temperature: data["daily"]["temperature_2m_min"][0]
      }
    else
      raise ForecastingError, "Open Meteo Request Failed"
    end
  end
end