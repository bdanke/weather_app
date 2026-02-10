require "rails_helper"

RSpec.describe OpenMeteoService do
  let(:coordinates) { { lat: 30, lon: 50 } }

  let(:success_body) do
    {
      current: { temperature: 32 },
      daily: {
        temperature_2m_max: [37],
        temperature_2m_min: [17]
      }
    }.to_json
  end

  let(:query_params) do
    {
      latitude: 30,
      longitude: 50,
      daily: "temperature_2m_max,temperature_2m_min",
      current: "temperature",
      forecast_days: "1"
    }
  end

  describe ".retrieve_forecast" do
    it "sends the correct query parameters" do
      request_stub = stub_request(:get, "https://api.open-meteo.com/v1/forecast")
        .with(query: query_params)
        .to_return(status: 200, body: success_body)

      described_class.retrieve_forecast(coordinates)

      expect(request_stub).to have_been_requested
    end

    context "when the API returns a 200 response" do
      before do
        stub_request(:get, "https://api.open-meteo.com/v1/forecast")
          .with(query: query_params)
          .to_return(status: 200, body: success_body)
      end

      it "returns the current temperature" do
        result = described_class.retrieve_forecast(coordinates)
        expect(result[:current_temperature]).to eq(32)
      end

      it "returns the maximum temperature" do
        result = described_class.retrieve_forecast(coordinates)
        expect(result[:maximum_temperature]).to eq(37)
      end

      it "returns the minimum temperature" do
        result = described_class.retrieve_forecast(coordinates)
        expect(result[:minimum_temperature]).to eq(17)
      end
    end

    context "when the API returns a non-200 response" do
      before do
        stub_request(:get, "https://api.open-meteo.com/v1/forecast")
          .with(query: query_params)
          .to_return(status: 500, body: "Internal Server Error")
      end

      it "raises a ForecastingError" do
        expect { described_class.retrieve_forecast(coordinates) }
          .to raise_error(ForecastingError, "Open Meteo Request Failed")
      end
    end
  end
end
