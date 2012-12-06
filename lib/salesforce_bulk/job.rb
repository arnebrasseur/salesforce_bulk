require 'salesforce_bulk/job/job_info'
require 'salesforce_bulk/job/batch_info'


module SalesforceBulk
  class Job
    XML_HEADER = '<?xml version="1.0" encoding="utf-8" ?>'

    attr_accessor :result
    attr_reader   :job_info

    def initialize(operation, sobject, external_field, connection)
      @operation      = operation
      @sobject        = sobject
      @external_field = external_field
      @connection     = connection
      @job_info       = nil
      @batch_info     = nil
      @result         = JobResult.new
    end

    def create_job()
      xml = "#{XML_HEADER}<jobInfo xmlns=\"http://www.force.com/2009/06/asyncapi/dataload\">"
      xml += "<operation>#{@operation}</operation>"
      xml += "<object>#{@sobject}</object>"
      if !@external_field.nil? # This only happens on upsert
        xml += "<externalIdFieldName>#{@external_field}</externalIdFieldName>"
      end
      xml += "<contentType>CSV</contentType>"
      xml += "</jobInfo>"

      path = "job"
      headers = Hash['Content-Type' => 'application/xml; charset=utf-8']

      post_job(path, xml, headers)
    end

    def close_job()
      xml = "#{XML_HEADER}<jobInfo xmlns=\"http://www.force.com/2009/06/asyncapi/dataload\">"
      xml += "<state>Closed</state>"
      xml += "</jobInfo>"

      path = "job/#{job_id}"
      headers = Hash['Content-Type' => 'application/xml; charset=utf-8']

      post_job(path, xml, headers)
    end


    def add_query(records)
      path = "job/#{job_id}/batch/"
      headers = Hash["Content-Type" => "text/csv; charset=UTF-8"]
      
      response = @connection.post_xml(nil, path, records, headers)

      post_batch(path, records, headers)
    end

    def add_batch(records)
      keys = records.first.keys
      
      output_csv = keys.to_csv

      records.each do |r|
        fields = Array.new
        keys.each do |k|
          fields.push(r[k])
        end

        row_csv = fields.to_csv
        output_csv += row_csv
      end

      path = "job/#{job_id}/batch/"
      headers = Hash["Content-Type" => "text/csv; charset=UTF-8"]

      post_batch(path, output_csv, headers)
    end

    def check_batch_status()
      path = "job/#{job_id}/batch/#{@batch_id}"
      headers = Hash.new

      response = @connection.get_request(nil, path, headers)
      @batch_info = BatchInfo.new(response['batchInfoList'])
    end

    def get_batch_result()
      path = "job/#{job_id}/batch/#{@batch_id}/result"
      headers = Hash["Content-Type" => "text/xml; charset=UTF-8"]

      response = @connection.get_request(nil, path, headers)

      if(@operation == "query") # The query op requires us to do another request to get the results
        result_id = response['jobInfo']["result"]

        path = "job/#{job_id}/batch/#{@batch_id}/result/#{result_id}"
        headers = Hash.new
        headers = Hash["Content-Type" => "text/xml; charset=UTF-8"]
        
        response = @connection.get_request(nil, path, headers)
      end

      parse_results response

      response = response.lines.to_a[1..-1].join
      # csvRows = CSV.parse(response, :headers => true)
    end

    def parse_results response
      @result.success = true
      @result.raw = response.body
      csvRows = CSV.parse(response, :headers => true)

      csvRows.each_with_index  do |row, index|
        if @operation != "query"
          row["Created"] = row["Created"] == "true" ? true : false
          row["Success"] = row["Success"] == "true" ? true : false
        end

        @result.records.push row
        if row["Success"] == false
          @result.success = false 
          @result.errors.push({"#{index}" => row["Error"]}) if row["Error"]
        end
      end

      @result.message = "The job has been closed."
    end

    def job_id
      job_info.job_id
    end

    def batch_id
      batch_info.batch_id
    end

    private

    def post_batch(path, payload, headers)
      response = @connection.post_xml(nil, path, payload, headers)
      @connection.raise_if_has_errors( response )
      
      @batch_info = BatchInfo.new(response)
    end     

    def post_job(path, xml, headers)
      response = @connection.post_xml(nil, path, xml, headers)
      @connection.raise_if_has_errors( response )
      
      @job_info = JobInfo.new(response)
    end

  end

  class JobResult
    attr_writer :errors, :success, :records, :raw, :message
    attr_reader :errors, :success, :records, :raw, :message

    def initialize
      @errors = []
      @success = nil
      @records = []
      @raw = nil
      @message = 'The job has been queued.'
    end

    def success?
      @success
    end

    def has_errors?
      @errors.count > 0
    end
  end

end
