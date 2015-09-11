require 'rubygems'
require 'twilio-ruby'
require 'sinatra'

get '/search' do
  message = params[:Body]
  twiml = Twilio::TwiML::Response.new do |r|
    r.Message "Hey Guy. Thanks for sending #{message}!"
  end
  twiml.text
end