class ForecastsController < ApplicationController
  # Geocodes the submitted address and fetches the weather forecast,
  # caching the result for 30 minutes keyed by postal code.
  def retrieve_forecast
    postal_code = address_params[:postal_code]

    begin
      @forecast = Rails.cache.fetch("#{postal_code}/forecast", expires_in: 30.minutes) do
        coordinates = GeocodeService.geocode(address_params)
        forecast = OpenMeteoService.retrieve_forecast(coordinates)
        forecast[:postal_code] = postal_code
        forecast
      end
    rescue GeocodingError, ForecastingError => e
      redirect_to root_path, alert: e.message
    end
  end

  private

  def address_params
    params.permit(:street, :city, :state, :postal_code, :country, :authenticity_token, :commit)
  end
end
