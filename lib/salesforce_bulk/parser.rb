module SalesforceBulk
  class Parser < HTTParty::Parser
    SupportedFormats.merge!(
      'text/csv' => :csv
    )

    def parse
      if format.nil?
        MultiXml.parse(body)
      else
        super
      end
    end

    def csv
      CSV.parse(body, :headers => true)
    end
  end
end
