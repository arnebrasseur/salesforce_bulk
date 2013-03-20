module SalesforceBulk

  class Connection
    include HTTParty
    parser SalesforceBulk::Parser

    attr_accessor :username, :password, :session_id, :server_url, :instance, :api_version, :login_host, :instance_host, :debug

    def initialize(username, password, api_version, login_host)
      @username    = username
      @password    = password
      @api_version = api_version
      @login_host  = login_host

      login
    end

    def login
      xml = XmlTemplates.login( @username, @password )
      headers = {'Content-Type' => 'text/xml; charset=utf-8', 'SOAPAction' => 'login'}

      response = do_post!(login_host, login_path, xml, headers)
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

    def do_post(path, xml, headers = nil)
      response = do_post!(nil, path, xml, headers)
      raise_if_has_errors(response)
      response
    end

    def do_post!(host, path, xml, headers = nil)
      headers ||= default_headers
      path = prefix_path(path) unless host == @login_host
      add_session_header(headers, host)
      perform(:post, path, :body => xml, :headers => headers, :base_uri => base_uri(host))
    end

    def do_get(path, headers = nil)
      response = do_get!(nil, path, headers)
      raise_if_has_errors(response)
      response
    end

    def do_get!(host, path, headers = nil)
      headers ||= default_headers
      add_session_header(headers, host)
      perform(:get, prefix_path(path), :headers => headers, :base_uri => base_uri(host))
    end

    def default_headers
      { 'Content-Type' => 'application/xml; charset=utf-8' }
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
      headers['X-SFDC-Session'] = @session_id  if  @session_id
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
      @debug << _xml_pp(response.body.force_encoding('UTF-8')) << "\n"
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
