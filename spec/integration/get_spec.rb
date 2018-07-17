require "spec_helper"

describe "Integration Specs" do

  describe "SQLi" do

    describe "GET" do
      it "allows a request without an attack vector" do
        http = Curl.get("http://127.0.0.1:8888")
        expect(http.response_code).to eq(200)
      end

      it "blocks a request with an attack vector" do
        http = Curl.get("http://127.0.0.1:8888", { attack: "' OR 1=1; --" })
        expect(http.response_code).to eq(403)
      end

      it "allows a request to a proxy without an attack vector" do
        http = Curl.get("http://127.0.0.1:8888/sinatra/simple")
        expect(http.response_code).to eq(200)
      end

      it "allows a request to a proxy without an attack vector with params" do
        http = Curl.get("http://127.0.0.1:8888/sinatra/simple", { a: 1, b: 2, c: { d: [ 1, 2, 3] } } )
        expect(http.response_code).to eq(200)
      end

      it "blocks a request with an attack vector" do
        http = Curl.get("http://127.0.0.1:8888/sinatra/simple", { attack: "' OR 1=1; --" })
        expect(http.response_code).to eq(403)
      end
    end
  end
end
