require "rails_helper"

RSpec.describe GeocodeService do
  let(:address_params) do
    {
      street: "476 5th Ave.",
      city: "New York",
      state: "NY",
      postal_code: "10018",
      country: "USA"
    }
  end

  let(:success_body) do
    [
      {
        "lat" => 30,
        "lon" => 50
      }
    ].to_json
  end

  let(:expected_query_params) do
    {
      street: "476 5th Ave.",
      city: "New York",
      state: "NY",
      postalcode: "10018",
      country: "USA",
      api_key: "XYZ",
      limit: 1
    }
  end

  describe ".geocode" do
    before do
      allow(ENV).to receive(:[]).with("GEOCODE_API_KEY").and_return("XYZ")
    end

    it "sends the correct query parameters including API key" do
      request_stub = stub_request(:get, "https://geocode.maps.co/search")
        .with(query: expected_query_params)
        .to_return(status: 200, body: success_body)

      described_class.geocode(address_params)

      expect(request_stub).to have_been_requested
    end

    context "when the API returns a 200 response" do
      before do
        stub_request(:get, "https://geocode.maps.co/search")
          .with(query: hash_including(postalcode: "10018"))
          .to_return(status: 200, body: success_body)
      end

      it "return the latitude" do
        result = described_class.geocode(address_params)
        expect(result[:lat]).to eq(30)
      end

      it "return the longitude" do
        result = described_class.geocode(address_params)
        expect(result[:lon]).to eq(50)
      end
    end

    context "when the API returns a non-200 response" do
      before do
        stub_request(:get, "https://geocode.maps.co/search")
          .with(query: hash_including(postalcode: "10018"))
          .to_return(status: 500, body: "Internal Server Error")
      end

      it "raises a GeocodingError" do
        expect { described_class.geocode(address_params) }
          .to raise_error(GeocodingError, "Geocode Request Failed")
      end
    end

    it "uses the first result from the response array" do
      result_body = [
        { "lat" => "30", "lon" => "50" },
        { "lat" => "50", "lon" => "60" }
      ].to_json

      stub_request(:get, "https://geocode.maps.co/search")
        .with(query: hash_including(postalcode: "10018"))
        .to_return(status: 200, body: result_body)

      result = described_class.geocode(address_params)

      expect(result[:lat]).to eq("30")
      expect(result[:lon]).to eq("50")
    end
  end
end