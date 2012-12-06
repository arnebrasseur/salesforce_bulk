require 'salesforce_bulk/job/response_object'

module SalesforceBulk
  class BatchInfo < ResponseObject

    def closed?
      state == 'Closed'
    end

    def batch_id
      field 'id'
    end

    FIELDS = %w(
      jobId
      state
      createdDate
      systemModstamp
      numberRecordsProcessed
      numberRecordsFailed
      totalProcessingTime
      apiActiveProcessingTime
      apexProcessingTime
    )

  end
end

# <batchInfo xmlns='http://www.force.com/2009/06/asyncapi/dataload'>
#   <id>751d0000000XxA1AAK</id>
#   <jobId>750d0000000QlqkAAC</jobId>
#   <state>Queued</state>
#   <createdDate>2012-11-23T10:55:58.000Z</createdDate>
#   <systemModstamp>2012-11-23T10:55:58.000Z</systemModstamp>
#   <numberRecordsProcessed>0</numberRecordsProcessed>
#   <numberRecordsFailed>0</numberRecordsFailed>
#   <totalProcessingTime>0</totalProcessingTime>
#   <apiActiveProcessingTime>0</apiActiveProcessingTime>
#   <apexProcessingTime>0</apexProcessingTime>
# </batchInfo>
