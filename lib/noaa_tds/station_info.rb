# frozen_string_literal: true

module NoaaTds
  class StationInfo
    def self.stations_by_identifier(str)
      response = Request.get(build_uri(str))

      raise Error.new("Error getting station info") if response == :well_shit

      response.css('response data Station').map do |resp|
        new(str, resp: resp)
      end
    end

    def self.build_uri(id)
      params = {
        dataSource: "stations",
        requestType: "retrieve",
        format: "xml",
        stationString: id
      }

      NoaaTds::URI.clone.tap {|uri| uri.query = ::URI.encode_www_form(params)}
    end

    ATTRS = %i{
      station_id
      wmo_id
      latitude
      longitude
      elevation_m
      site
      state
      country
      site_type
    }

    attr_reader :id, :wmo_id, :latitude, :longitude, :elevation_m, :site, :state,
      :country, :site_type

    def initialize(id, resp: nil)
      @id = id
      parse_response(resp) if resp
    end

    private

    def parse_response(resp)
      attrs = ATTRS.each_with_object({}) do |attr, out|
        out[attr] = resp.at_css(attr)
      end

      @id = attrs.delete(:station_id).text
      @site_type = attrs.delete(:site_type)&.elements&.map {|e| e.name}

      attrs.each do |name, value|
        instance_variable_set(:"@#{name}", value&.text)
      end
    end
  end
end
