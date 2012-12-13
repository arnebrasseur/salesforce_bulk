require 'salesforce_bulk/job/job_info'

module SalesforceBulk
  class Job

    attr_accessor :result
    attr_reader :job_info, :batches, :operation, :sobject, :external_field, :connection

    def initialize(operation, sobject, external_field, connection)
      @operation      = operation
      @sobject        = sobject
      @external_field = external_field
      @connection     = connection
      @job_info       = nil
      @batches        = []
    end

    def execute
      create
      batches.each( &:execute )
      close

      unfinished = batches.select {|batch| batch.state == "Queued" || batch.state == "InProgress"}
      until unfinished.empty?
        sleep(2)
        unfinished.each( &:update_status )
        unfinished = batches.select {|batch| batch.state == "Queued" || batch.state == "InProgress"}
      end

      batches.each( &:retreive_results )

      self
    end

    def create
      xml = XmlTemplates.create_job( @operation, @sobject, @external_field )
      post_job( job_path, xml )
    end

    #def add_query(query)
    #  post_batch( batch_path, query )
    #end

    def add_batch(records)
      batches << Batch.new( self, records, connection )
    end

    def close
      xml = XmlTemplates.close_job
      post_job( job_path( job_id ), xml ) 
    end


    def job_id ; job_info.job_id ; end
    def results ; batches.map( &:results ).flatten ; end

    private

    def job_path( job_id = nil )
      ['job' , job_id].compact.join('/')
    end

    def post_job(path, xml, headers = nil)
      response = @connection.do_post(path, xml, headers)
      if response['jobInfo']
        @job_info = JobInfo.new(response)
      end
      response
    end

  end
end
