# frozen_string_literal: true

require "net/http"
require "nokogiri"

module NoaaTds
  module Request
    module_function

    def get(uri)
      response = Net::HTTP.get_response(uri)

      body = case response
      when Net::HTTPOK
        response.body
      else
        :well_shit
      end

      Nokogiri.parse(body)
    end
  end
end
