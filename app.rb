require 'rubygems'
require 'twilio-ruby'
require 'sinatra'
require 'weather-underground'
#%w(rubygems wordnik).each {|lib| require lib}

#Wordnik.configure do |config|
#  config.api_key = 'YOUR_API_KEY_HERE'
#end

# Specify that we're going to use the Weather Underground API(no key somehow)
w = WeatherUnderground::Base.new

# http://api.wordnik.com:80/v4/word.json/pace/definitions?limit=3&includeRelated=true&sourceDictionaries=webster&useCanonical=true&includeTags=false&api_key=a2a73e7b926c924fad7001ca3111acd55af2ffabf50eb4ae5
get '/search' do
  place = params[:Body]
  currentWeather = w.CurrentObservations(place)
  twiml = Twilio::TwiML::Response.new do |r|
    #definitions = Wordnik.word.get_definitions(word)
    r.Message "Current temp in #{currentWeather.display_location[0].full}: #{currentWeather.temp_c} °C"
  end
  twiml.text
end