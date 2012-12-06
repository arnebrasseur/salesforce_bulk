module SalesforceBulk

  class Connection
    XML_HEADER = '<?xml version="1.0" encoding="utf-8" ?>'

    include HTTParty

    attr_accessor :username, :password, :session_id, :server_url, :instance, :api_version, :login_host, :instance_host, :debug

    def initialize(username, password, api_version, in_sandbox = false)
      @username = username
      @password = password
      @api_version = api_version
      @login_host = in_sandbox ? 'login.salesforce.com' : 'test.salesforce.com'

      login
    end

    def login
      xml = XML_HEADER.dup
      xml << "<env:Envelope xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\""
      xml << "    xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\""
      xml << "    xmlns:env=\"http://schemas.xmlsoap.org/soap/envelope/\">"
      xml << "  <env:Body>"
      xml << "    <n1:login xmlns:n1=\"urn:partner.soap.sforce.com\">"
      xml << "      <n1:username>#{@username}</n1:username>"
      xml << "      <n1:password>#{@password}</n1:password>"
      xml << "    </n1:login>"
      xml << "  </env:Body>"
      xml << "</env:Envelope>"
      
      headers = {'Content-Type' => 'text/xml; charset=utf-8', 'SOAPAction' => 'login'}

      response = post_xml(login_host, login_path, xml, headers)
      raise_if_has_errors(response)

      @session_id = response['Envelope']['Body']['loginResponse']['result']['sessionId']
      @server_url = response['Envelope']['Body']['loginResponse']['result']['serverUrl']
      
      @instance_host = "#{ extract_instance(@server_url) }.salesforce.com"
    end

    def raise_if_has_errors(response)
      body = response.body

      if body =~ /faultstring/i || body =~ /exceptionmessage/i
        begin
          
          if body =~ /faultstring/i
            error_message = response['Envelope']['Body']['Fault']['faultstring']
          elsif body =~ /exceptionmessage/i
            error_message = response['error']['exceptionMessage']
          end

        rescue
          raise "An unknown error has occured within the salesforce_bulk gem. This is most" +
                "likely caused by bad request, but I am unable to parse the correct error message." +
                " Here is a dump of the response for your convenience. #{response}"
        end

        raise error_message
      end
    end

    def post_xml(host, path, xml, headers)
      path = prefix_path(path) unless host == @login_host
      add_session_header(headers, host)
      perform(:post, path, :body => xml, :headers => headers, :base_uri => base_uri(host))
    end

    def get_request(host, path, headers)
      add_session_header(headers, host)
      perform(:get, prefix_path(path), :headers => headers, :base_uri => base_uri(host))
    end

    private

    def perform(verb, path, options)
      _debug_request(verb.to_s.upcase, options[:base_uri] + ' ' + path, options[:headers], options[:body])
      response = self.class.send(verb, path, options)
      _debug_response(response)
      response
    end

    def login_path
      "/services/Soap/u/#{ api_version }"
    end

    def path_prefix
      "/services/async/#{ api_version }/"
    end

    def base_uri(host)
      host = host || @instance_host
      HTTParty.normalize_base_uri("https://#{host}")
    end

    def prefix_path(path)
      "#{ path_prefix }#{ path }"
    end

    def add_session_header(headers, host)
      if host != @login_host # Not login, need to add session id to header
        headers['X-SFDC-Session'] = @session_id;
      end
    end

    def extract_instance(server_url)
      server_url[/https:\/\/([a-z]{2,2}[0-9]{1,2})-api/, 1]
    end


    ## debug methods
    def _debug_request(verb, path, headers, xml = nil)
      return unless @debug
      @debug << "************** #{verb} #{path} #{headers.inspect}\n"
      @debug << _xml_pp(xml) << "\n**************\n" if xml
    end

    def _debug_response(response)
      return unless @debug
      @debug << _xml_pp(response.body) << "\n"
    end

    def _xml_pp(xml)
      begin
        format = REXML::Formatters::Pretty.new
        format.compact = true
        format.write(REXML::Document.new(xml).root,"")
      rescue Object => e
        xml
      end
    end
    ###
  end

end
