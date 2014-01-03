# encoding: utf-8
require 'twilio-ruby'

class Clue
  attr_reader :session

  PLACES = [
    [:nola, /nola/i, "NOLA"],
    [:casita, /casita/i, "Casita"],
    [:happiness, /happiness( *)forget/i, "Happiness Forgets"]
  ]
  CLUES = {
    :nola => 'AAAA',
    :casita => 'CCCC',
    :happiness => 'HFHF'
  }
  DESTINATION = "The final destination = ALKJKD"

  def initialize(session)
    @session = session
  end

  def name
    session[:name]
  end

  def talk(params)
    msg = params['Body']
    response = []
    if 'reset' == msg
      session.clear
      return Twilio::TwiML::Response.new do |r|
        r.Sms 'all clear'
      end
    end
    case session[:state]
    when :bored
      response << "Hi #{name} I'm confused"
    when :finish
      response << "Hi #{name} I'm confused"
    when :hunt
      response = "Nope, nope, nope"
      PLACES.each do |key, pattern, place|
        if pattern =~ msg
          session[key] = true
          response << "#{place} = #{CLUES[key]}"
          break
        end
      end
      if [session[:nola], session[:casita], session[:happiness]].all?
        session[:state] = :finish
        response << DESTINATION
      end
    when :intro
      session[:state] = :hunt
      session[:name] = msg
      response << "Hi #{name}"
      response << "let's go hunting…"
    else
      session[:state] = :intro
      response << "Hi, what's your name?"
    end
    Twilio::TwiML::Response.new do |r|
      response.each do |line|
        r.Sms line
      end
    end
  end
end
