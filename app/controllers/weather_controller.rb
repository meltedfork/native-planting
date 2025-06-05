class WeatherController < ApplicationController
  require "open-uri"
  def index
    # Show the form
  end

  def create
    # Get coordinates from location
    location = find_location

    if location.present?
      lat = location.first["lat"]
      lon = location.first["lon"]
      # Get weather data
      @weather = fetch_weather(lat, lon)
      redirect_to weather_show_path(lat: lat, lon: lon)
    else
      flash[:error] = "Location not found"
      redirect_to weather_path
    end
  end

def show
  lat = params[:lat]
  lon = params[:lon]
  if lat.present? && lon.present?
    @weather = fetch_weather(lat, lon)
  else
    flash[:error] = "Missing coordinates"
    redirect_to weather_path
  end
end

  private

  def location_params
    params.permit(:city, :state, :country, :authenticity_token, :commit)
  end

  def find_location
    location = location_params
    q = [ location[:city], location[:state], location[:country] ].compact.join(",")
    url = "http://api.openweathermap.org/geo/1.0/direct?q=#{q}&units=imperial&limit=1&appid=#{Rails.application.credentials.open_weather}"
    response = URI.open(url)
    JSON.parse(response.read)
  end

  def fetch_weather(lat, lon)
    url = "https://api.openweathermap.org/data/2.5/weather?lat=#{lat}&lon=#{lon}&units=imperial&appid=#{Rails.application.credentials.open_weather}"
    #  Rails.logger.info("This is the weather URL created: #{url}")
    response = URI.open(url)
    JSON.parse(response.read)
  end
end
