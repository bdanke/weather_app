require "rails_helper"

RSpec.describe ForecastsController, type: :request do
  let(:address_params) do
    {
      street: "476 5th Ave.",
      city: "New York",
      state: "NY",
      postal_code: "10018",
      country: "USA"
    }
  end

  let(:coordinates) do
    {
      lat: 30,
      lon: 50
    }
  end

  let(:forecast_data) do
    {
      current_temperature: 32,
      maximum_temperature: 37,
      minimum_temperature: 17
    }
  end

  describe "POST /retrieve_forecast" do
    before do
      allow(GeocodeService).to receive(:geocode).and_return(coordinates)
      allow(OpenMeteoService).to receive(:retrieve_forecast).and_return(forecast_data)
    end

    it "returns a successful response" do
      post "/retrieve_forecast", params: address_params, as: :turbo_stream

      expect(response).to have_http_status(:success)
    end

    it "calls GeocodeService with the address params" do
      post "/retrieve_forecast", params: address_params, as: :turbo_stream

      expect(GeocodeService).to have_received(:geocode).with(
        ActionController::Parameters.new(address_params).permit(
          :street, :city, :state, :postal_code, :country
        )
      )
    end

    it "calls OpenMeteoService with the coordinates" do
      post "/retrieve_forecast", params: address_params, as: :turbo_stream

      expect(OpenMeteoService).to have_received(:retrieve_forecast).with(coordinates)
    end

    context "when the forecast is cached" do
      before do
        Rails.cache.clear
        allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache.lookup_store(:memory_store))
      end

      it "does not call the services again on the second request" do
        post "/retrieve_forecast", params: address_params, as: :turbo_stream

        post "/retrieve_forecast", params: address_params, as: :turbo_stream

        expect(GeocodeService).to have_received(:geocode).once
        expect(OpenMeteoService).to have_received(:retrieve_forecast).once
      end

      it "calls the services again for a different postal code" do
        post "/retrieve_forecast", params: address_params, as: :turbo_stream

        different_params = address_params.merge(postal_code: "90210")
        post "/retrieve_forecast", params: different_params, as: :turbo_stream

        expect(GeocodeService).to have_received(:geocode).twice
        expect(OpenMeteoService).to have_received(:retrieve_forecast).twice
      end
    end

    context "when GeocodeService raises a GeocodingError" do
      before do
        allow(GeocodeService).to receive(:geocode).and_raise(GeocodingError, "Geocode Request Failed")
      end

      it "does not return a successful response" do
        post "/retrieve_forecast", params: address_params, as: :turbo_stream

        expect(response).not_to have_http_status(:success)
        expect(flash[:alert]).to eq("Geocode Request Failed")
      end
    end

    context "when OpenMeteoService raises a ForecastingError" do
      before do
        allow(OpenMeteoService).to receive(:retrieve_forecast).and_raise(ForecastingError, "Open Meteo Request Failed")
      end

      it "does not return a successful response" do
        post "/retrieve_forecast", params: address_params, as: :turbo_stream

        expect(response).not_to have_http_status(:success)
        expect(flash[:alert]).to eq("Open Meteo Request Failed")
      end
    end
  end
end
