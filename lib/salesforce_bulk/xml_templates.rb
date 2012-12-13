module SalesforceBulk
  module XmlTemplates
    extend self

    XML_HEADER = '<?xml version="1.0" encoding="utf-8" ?>'

    def create_job( operation, sobject, external_field )
      build do |xml|
        xml << "<jobInfo xmlns=\"http://www.force.com/2009/06/asyncapi/dataload\">"
        xml << "  <operation>#{operation}</operation>"
        xml << "  <object>#{sobject}</object>"
        xml << "  <externalIdFieldName>#{external_field}</externalIdFieldName>" unless external_field.nil? # only for upsert
        xml << "  <contentType>CSV</contentType>"
        xml << "</jobInfo>"
      end
    end

    def close_job
      build do |xml|
        xml << '<jobInfo xmlns="http://www.force.com/2009/06/asyncapi/dataload">'
        xml << '  <state>Closed</state>'
        xml << '</jobInfo>'
      end
    end

    def login( username, password )
      build do |xml|
        xml << '<env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" '
        xml << '    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  '
        xml << '    xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"> '
        xml << '  <env:Body>'
        xml << '    <n1:login xmlns:n1="urn:partner.soap.sforce.com">'
        xml << "      <n1:username>#{username}</n1:username>"
        xml << "      <n1:password>#{password}</n1:password>"
        xml << '    </n1:login>'
        xml << '  </env:Body>'
        xml << '</env:Envelope>'
      end
    end

    def build
      yield XML_HEADER.dup
    end
    
  end
end
