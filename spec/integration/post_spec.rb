require "spec_helper"

describe "Integration Specs" do

  before(:all) do
    `build/nginx/sbin/nginx`
    sleep 1
  end

  after(:all) do
    `build/nginx/sbin/nginx -s stop`
  end
  
  describe "SQLi" do
    describe "POST" do
      it "allows a request without an attack vector" do
        http = Curl.post("http://127.0.0.1:8888/sinatra/text", { a: 1, b: 2, c: { d: [1, 2, 3] }})
        expect(http.response_code).to eq(200)
      end

      it "blocks a request with an attack vector" do
        http = Curl.post("http://127.0.0.1:8888/sinatra/text", { attack: "alert(document.cookie)" })
        expect(http.response_code).to eq(403)
      end

      it "allows a request with a JSON body" do
        http = Curl.post("http://127.0.0.1:8888/sinatra/json", '{"alert": {"test": "there ia s document and a cookie in the lunchroom" } }') do |curl|
          curl.headers['Accept'] = 'application/json'
          curl.headers['Content-Type'] = 'application/json'
          curl.headers['Api-Version'] = '2.2'
        end

        expect(http.response_code).to eq(200)
      end

      it "blocks a request with a JSON attack vector" do
        http = Curl.post("http://127.0.0.1:8888/sinatra/json", '{"test": { "nested": {"attack": "alert(document.cookie)"} } }') do |curl|
          curl.headers['Accept'] = 'application/json'
          curl.headers['Content-Type'] = 'application/json'
          curl.headers['Api-Version'] = '2.2'
        end

        expect(http.response_code).to eq(403)
      end

      it "allows a request with an XML body" do
        http = Curl.post("http://127.0.0.1:8888/sinatra/xml", '<element attr="test"><alert><document/><cookie/></alert></element>') do |curl|
          curl.headers['Accept'] = 'text/xml'
          curl.headers['Content-Type'] = 'text/xml'
          curl.headers['Api-Version'] = '2.2'
        end

        expect(http.response_code).to eq(200)
      end

      it "blocks a request with a XML attack vector" do
        http = Curl.post("http://127.0.0.1:8888/sinatra/xml", '<element attr="test">alert(document.cookie)</element>') do |curl|
          curl.headers['Accept'] = 'text/xml'
          curl.headers['Content-Type'] = 'text/xml'
          curl.headers['Api-Version'] = '2.2'
        end

        expect(http.response_code).to eq(403)
      end
    end
  end
end