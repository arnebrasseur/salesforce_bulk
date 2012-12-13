require 'salesforce_bulk/job/batch_info'

module SalesforceBulk
  class Batch
    attr_accessor :job, :batch_info, :records, :connection, :results

    def initialize( job, records, connection )
      @job, @records, @connection = job, records, connection
    end

    def execute
      keys = records.first.keys
      csv  = keys.to_csv
      csv += records.map { |r| r.values_at(*keys).to_csv }.join

      result     = connection.do_post( batch_path, csv, "Content-Type" => "text/csv; charset=UTF-8" )
      self.batch_info = BatchInfo.new( result )
    end

    def update_status
      self.batch_info = BatchInfo.new( connection.do_get( batch_path( batch_id ) ) )
      self
    end

    def retreive_results
      batch_result = connection.do_get( batch_result_path )

      #if @operation == "query" # The query op requires us to do another request to get the results
      #  result_id = batch_result.result
      #  batch_result = perform_get( batch_result_path( result_id ) )
      #end
      
      self.results = batch_result.parsed_response.map do |row|
        #if @operation != "query"
        row["Created"] = (row["Created"] == "true")
        row["Success"] = (row["Success"] == "true")
        #end
        row
      end

      self.results
    end

    def batch_path( id = nil )
      "job/#{job_id}/batch/#{ id }"
    end

    def batch_result_path( id = nil )
      "job/#{job_id}/batch/#{batch_id}/result/#{ id }"
    end

    def state    ; batch_info && batch_info.state ; end
    def job_id   ; job.job_id ; end
    def batch_id ; batch_info.batch_id ; end

  end
end
