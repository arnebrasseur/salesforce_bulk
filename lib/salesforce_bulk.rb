require 'httparty'
require 'csv'

require 'salesforce_bulk/version'
require 'salesforce_bulk/xml_templates'
require 'salesforce_bulk/parser'
require 'salesforce_bulk/batch'
require 'salesforce_bulk/job'
require 'salesforce_bulk/connection'

module SalesforceBulk
  # Your code goes here...
  class Api
    SALESFORCE_API_VERSION = '26.0'

    attr_reader :connection
    def initialize(username, password, login_host = 'login.salesforce.com', version = SALESFORCE_API_VERSION)
      @connection = SalesforceBulk::Connection.new(username, password, version, login_host)
    end

    def upsert(sobject, records, external_field, wait=false)
      return if records.empty?
      self.do_operation('upsert', sobject, records, external_field, wait)
    end

    def update(sobject, records, wait=false)
      return if records.empty?
      self.do_operation('update', sobject, records, nil, wait)
    end
    
    def create(sobject, records, wait=false)
      return if records.empty?
      self.do_operation('insert', sobject, records, nil, wait)
    end

    def delete(sobject, records, wait=false)
      return if records.empty?
      self.do_operation('delete', sobject, records, nil, wait)
    end

    def query(sobject, query)
      self.do_operation('query', sobject, query, nil)
    end

    def do_operation(operation, sobject, records_or_query, external_field, wait=false)
      job = SalesforceBulk::Job.new(operation, sobject, external_field, @connection)

      if(operation == "query")
        job.add_query( records_or_query )
      else
        job.add_batch( records_or_query )
      end

      job.execute
    end

    def parse_batch_result result
      begin
        CSV.parse(result, :headers => true)
      rescue
        result
      end
    end

    def debug      ; @connection.debug      ; end
    def debug=(io) ; @connection.debug = io ; end

  end  # End class
end # End module
