require 'spec_helper'

module Awsum
  describe Error do
    subject {
      response = mock(:response, :code => 404, :body => fixture('ec2/invalid_request_error'))
      Error.new(response)
    }
    let(:error) { subject }

    it "should return the correct response code" do
      error.response_code.should == 404
    end

    it "should return the correct code" do
      error.code.should == 'InvalidRequest'
    end

    it "should return the correct message" do
      error.message.should == 'The request received was invalid.'
    end

    it "should return the correct request id" do
      error.request_id.should == '7cbacf61-c7df-468a-8130-cf5d659f8144'
    end

    it "should return the correct additional info" do
      error.additional.should == {'Unknown' => 'Test message'}
    end
  end
end
