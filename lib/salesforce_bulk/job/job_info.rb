require 'salesforce_bulk/job/response_object'

module SalesforceBulk
  class JobInfo < ResponseObject

    def closed?
      state == 'Closed'
    end

    def queued?
      state == 'Queued'
    end

    def job_id
      field 'id'
    end

    FIELDS = %w(
      operation
      object
      createdById
      createdDate
      systemModstamp
      state
      externalIdFieldName
      concurrencyMode
      contentType
      apiVersion
      totalProcessingTime
      apiActiveProcessingTime
      apexProcessingTime
    )

    INT_FIELDS = %w(
      numberBatchesQueued
      numberBatchesInProgress
      numberBatchesCompleted
      numberBatchesFailed
      numberBatchesTotal
      numberRecordsProcessed
      numberRecordsFailed
      numberRetries
    )
    
  end
end


# <jobInfo xmlns='http://www.force.com/2009/06/asyncapi/dataload'>
#   <id>750d0000000QlqkAAC</id>
#   <operation>upsert</operation>
#   <object>OpportunityLineItem</object>
#   <createdById>005d0000001HYSVAA4</createdById>
#   <createdDate>2012-11-23T10:55:56.000Z</createdDate>
#   <systemModstamp>2012-11-23T10:55:56.000Z</systemModstamp>
#   <state>Closed</state>
#   <externalIdFieldName>Ticketsolve__TicketsolveId__c</externalIdFieldName>
#   <concurrencyMode>Parallel</concurrencyMode>
#   <contentType>CSV</contentType>
#   <numberBatchesQueued>1</numberBatchesQueued>
#   <numberBatchesInProgress>0</numberBatchesInProgress>
#   <numberBatchesCompleted>0</numberBatchesCompleted>
#   <numberBatchesFailed>0</numberBatchesFailed>
#   <numberBatchesTotal>1</numberBatchesTotal>
#   <numberRecordsProcessed>0</numberRecordsProcessed>
#   <numberRetries>0</numberRetries>
#   <apiVersion>26.0</apiVersion>
#   <numberRecordsFailed>0</numberRecordsFailed>
#   <totalProcessingTime>0</totalProcessingTime>
#   <apiActiveProcessingTime>0</apiActiveProcessingTime>
#   <apexProcessingTime>0</apexProcessingTime>
# </jobInfo>
