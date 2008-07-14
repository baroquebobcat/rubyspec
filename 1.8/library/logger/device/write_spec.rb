require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/../fixtures/common'

describe "Logger::LogDevice#write" do
  before  :each do
    @file_path = tmp("test_log.log")
    @log_file = File.open(@file_path, "w+")
    # Avoid testing this with STDERR, we don't want to be closing that.
    @device = Logger::LogDevice.new(@log_file)
  end

  after :all do
    File.unlink(@file_path) if File.exists?(@file_path)
  end


  it "writes a message to the device" do
    @device.write "This is a test message"
    @log_file.rewind
    @log_file.readlines.first.should == "This is a test message"
  end

  it "fails if the device is already closed" do
    @device.close
    lambda { @device.write "foo" }.should raise_error
  end
end
