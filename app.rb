require 'rubygems'
require 'twilio-ruby'
require 'sinatra'
require 'weather-underground'
require 'ruby-units'
require 'wikipedia'
require 'dictionary_lookup'

# Specify that we're going to use the Weather Underground API(no key somehow)
w = WeatherUnderground::Base.new

get '/search' do
  input = params[:Body]
  puts "The input was: #{input}"
  ### WEATHER ###
  if input and match = input.match(/^[weather|wx]+[ ]*([forecast|fc]*) ([\w ,.-]+)/i)
    forecast, location = match.captures
    puts "Location: #{location}"
    puts "Forecast: #{forecast}"
    if location and forecast != ""
      wxForecast = w.SimpleForecast(location)
      message = "Forecast is not *quite* supported yet"
    elsif location
      wxCurrent = w.CurrentObservations(location)
      puts "WX: #{wxCurrent.inspect}"
      message = "Current temp in #{wxCurrent.display_location[0].full}: #{wxCurrent.temp_c} °C"
    end
  end
  ### DEFINITIONS ###
  if input and match = input.match(/^[define|definition of]+ ([\w -]+)/i)
    puts "Word: #{match.captures[0]}"
    results = DictionaryLookup::Base.define(match.captures[0])
    puts "#{results.inspect}"
    message = "#{results.first.part_of_speech} - #{results.first.denotation}"
  end
  ### UNIT CONVERSIONS ###
  if input and match = input.match(/([\d]+[ ]*[ \w]+|\d'\d") [in|to]+ ([\w ]+)/i)
    from, to = match.captures
    unitFrom = from.to_unit
    unitTo = to.to_unit
    if unitFrom =~ unitTo
      message = "#{unitFrom.convert_to(to)}"
    else
      message = "Those units are incompatible"
    end
  end
  ### SPORTS SCORES ###
  #if input and match = input.match()

  #end
  ### WIKI ###
  if input and match = input.match(/^[wiki|wikipedia]+ ([\w ]+)/i)
    term = match.captures[0]
    puts "Term: #{term}"
    page = Wikipedia.find(term)
    message = "#{page.text}"
  end
  ### BASE CASE ###
  if !message
    message = "Sorry, I didn't understand that."
  end
  puts "The response is: #{message}"
  # Send the user's reply
  twiml = Twilio::TwiML::Response.new do |r|
    r.Message message.length > 140 ? message[0..140] : message
  end
  twiml.text
end