require 'webmock'
require 'webmock/rspec/matchers'
require "json"

class FakeApiService
  include WebMock::API
  include WebMock::Matchers

  attr_reader :username, :password, :login_host, :instance_host
  def initialize( username, password, login_host, instance_host )
    @username, @password, @login_host, @instance_host = username, password, login_host, instance_host

    stub_request( *login_request ).with(
      :body => /<n1:username>#{Regexp.escape(username)}<\/n1:username>\s*<n1:password>#{Regexp.escape(@password)}<\/n1:password>/,
      :headers => {'Content-Type'=>'text/xml; charset=utf-8', 'Soapaction'=>'login'}
    ).to_return(
      :body => {'Envelope' => {'Body' => {'loginResponse' => {'result' => { 'sessionId' => 'yyy', 'serverUrl' => instance_host }}}}}.to_json,
      :headers => { 'Content-Type' => 'application/json' }
    )
  end

  def login_request
    [ :post, "https://#{login_host}/services/Soap/u/#{SalesforceBulk::Api::SALESFORCE_API_VERSION}" ]
  end

  def should_have_received_login
    a_request( *login_request ).should have_been_made
  end
end
