require "httparty"
require "json"

class OpenMeteoService
  def self.retrieve_forecast(coordinates)
    response = HTTParty.get("https://api.open-meteo.com/v1/forecast",
      query: {
        latitude: data[:lat],
        longitude: data[:lon],
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
      raise "Open Meteo Request Failed"
    end
  end
end