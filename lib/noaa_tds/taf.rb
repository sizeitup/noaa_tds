# frozen_string_literal: true

module NoaaTds
  class TAF
    def self.for_flight_path(flight_path, distance: 40, hours_before_now: 1)
      uri = build_uri(
        flight_path: flight_path,
        distance: distance,
        hours_before_now: hours_before_now
      )
      response = Request.get(uri)

      raise Error.new("Error getting station info") if response == :well_shit

      response.css('response data TAF').map do |resp|
        new(resp: resp)
      end
    end

    def self.build_uri(distance:, flight_path:, hours_before_now: 1)
      params = {
        dataSource: "tafs",
        requestType: "retrieve",
        format: "xml",
        flightPath: "#{distance}; #{FlightPath.wrap(flight_path).to_param}",
        hoursBeforeNow: hours_before_now
      }

      NoaaTds::URI.clone.tap do |uri|
        query = ::URI.encode_www_form(params)
        query = query.gsub("%2C", ",").gsub("%3B", ";")
        uri.query = query
      end
    end

    ATTRS = %i{
      raw_text
      station_id
      issue_time
      bulletin_time
      valid_time_from
      valid_time_to
      latitude
      longitude
      elevation_m
    }

    attr_reader(*ATTRS)
    attr_reader :forecasts

    def initialize(resp:)
      parse_resp(resp)
    end

    class Forecast
      ATTRS = %i{
        fcst_time_from
        fcst_time_to
        wind_dir_degrees
        wind_speed_kt
        visibility_statute_mi
        sky_condition
      }

      attr_accessor(*ATTRS)
      private(*ATTRS.map {|a| :"#{a}="})

      def initialize(attrs)
        ATTRS.each do |attr|
          send(:"#{attr}=", attrs[attr])
        end
      end

      def sky_condition=(arg)
        @sky_condition = arg.map do |sc|
          SkyCondition.new(
            sc.attributes["sky_cover"]&.value,
            sc.attributes["cloud_base_ft_agl"]&.value
          )
        end
      end
    end

    SkyCondition = Struct.new(:sky_cover, :cloud_base_ft_agl)

    private

    def parse_resp(resp)
      ATTRS.each do |attr|
        instance_variable_set(:"@#{attr}", resp.at_css(attr)&.text)
      end

      @forecasts = resp.css("forecast").map do |fc|
        attrs = Forecast::ATTRS.each_with_object({}) do |attr, out|
          out[attr] = fc.at_css(attr)&.text
        end
        attrs[:sky_condition] = fc.css("sky_condition")

        Forecast.new(attrs)
      end
    end
  end
end
