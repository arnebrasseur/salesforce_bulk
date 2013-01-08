require 'salesforce_bulk'
require 'fake_api_service'

module SalesforceBulkTestGroup
  def self.included( group )
    group.instance_eval do
      let ( :username )      { 'abc@example.com' }
      let ( :password )      { 'pwd123super_secret' }
      let ( :login_host )    { 'login.host.com' }
      let ( :instance_host ) { 'instance.host.com' }

      let! ( :service ) { FakeApiService.new( username, password, login_host, instance_host ) }
    end
  end
end

RSpec.configure do |rspec|
  rspec.include SalesforceBulkTestGroup
  #rspec.treat_symbols_as_metadata_keys_with_true_values = true
end


