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
    :nola => '🌃🍊🍃🍎',
    :casita => '🐫🍎🌞👀👖🍏',
    :happiness => '🏠🍏🍕🐩👀🎶🍳🎅🌅 🐸🍊🐇🏆👂💦🍣',
    :princess => '🍕🐇👀🌃🐫🍳🌞🍣 🍊🐸 🌞🏠🍊🐇👂🐶👀👖🐫🏠'
  }
  DESTINATION = "The final destination = #{CLUES[:princess]}"

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
      taunts = [
        "I think this line's mostly filler",
        "Bored now",
        "Occasionally, I'm callous and strange",
        "Darn your sinister attraction",
        "Bunnies frighten me"
      ]
      response << taunts.sample
    when :finish
      session[:state] = :bored
      response << "Replace the symbols to find where you need to go"
    when :hunt
      reply = "Nope, nope, nope"
      PLACES.each do |key, pattern, place|
        if pattern =~ msg
          session[key] = true
          reply = "#{place} = #{CLUES[key]}"
          break
        end
      end
      response << reply
      if [session[:nola], session[:casita], session[:happiness]].all?
        session[:state] = :finish
        response << DESTINATION
      end
    when :intro
      session[:state] = :hunt
      session[:name] = msg
      response << "Hi #{name} let's go hunting…"
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
