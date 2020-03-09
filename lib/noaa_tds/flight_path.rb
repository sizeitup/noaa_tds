# frozen_string_literal: true

module NoaaTds
  class FlightPath
    def self.wrap(spec)
      return spec if spec.is_a?(FlightPath)
      new(spec)
    end

    attr_reader :points

    def initialize(points = [])
      @points = points.map {|s| Point.new(s)}
    end

    def <<(point)
      @points << Point.new(point)
    end

    def to_param
      points.map {|point| point.to_param}.join(";")
    end

    class Point
      attr_reader :spec

      def initialize(spec)
        @spec = spec
      end

      def to_param
        return spec if spec.include?(',')
        info = StationInfo.stations_by_identifier(spec).first
        "#{info.longitude},#{info.latitude}"
      end
    end
  end
end
