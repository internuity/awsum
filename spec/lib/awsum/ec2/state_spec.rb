require 'spec_helper'

module Awsum
  describe Ec2::State do
    let(:state) { Ec2::State.new(0, 'pending') }

    it "should be comparable to a number" do
      state.should == 0
    end
  end
end
