require 'spec_helper'

describe SalesforceBulk do
  it "should login" do
    SalesforceBulk::Api.new( username, password, login_host )

    service.should_have_received_login
  end
end
