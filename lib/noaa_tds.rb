# frozen_string_literal: true

require "noaa_tds/version"
require "uri"
require "noaa_tds/request"
require "noaa_tds/station_info"
require "noaa_tds/flight_path"
require "noaa_tds/taf"

module NoaaTds
  class Error < StandardError; end

  URI = URI("https://www.aviationweather.gov/adds/dataserver_current/httpparam")

  #?dataSource=stations&requestType=retrieve&format=xml&stationString=KDEN%20KSEA,%20PHNL
end
