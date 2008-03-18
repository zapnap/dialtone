require "dial_tone"

class TimeCheckerApp < DialTone
  answer "/" do
    erb("Welcome to my web app. Click <a href='/stuff/time/now'>here</a> to check the time.")
  end

  answer "/stuff/time/now" do
    erb("Current time is: <%= Time.now %>")
  end
end

Rack::Handler::Mongrel.run(TimeCheckerApp.new, {:Host => "127.0.0.1", :Port => 8080})
