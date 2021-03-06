require File.dirname(__FILE__) + '/spec_helper'

describe RequestLogAnalyzer::LogParser, "Rails" do
  include RequestLogAnalyzerSpecHelper
  
  before(:each) do
    @log_parser = RequestLogAnalyzer::LogParser.new(RequestLogAnalyzer::FileFormat.load(:rails))
  end
  
  it "should have a valid language definitions" do
    @log_parser.file_format.should be_valid
  end
  
  it "should parse a stream and find valid requests" do
    io = File.new(log_fixture(:rails_1x), 'r')
    @log_parser.parse_io(io) do |request| 
      request.should be_kind_of(RequestLogAnalyzer::Request)
    end
    io.close
  end  
  
  it "should find 4 completed requests" do
    @log_parser.should_not_receive(:warn)  
    @log_parser.should_receive(:handle_request).exactly(4).times
    @log_parser.parse_file(log_fixture(:rails_1x))
  end  
  
  it "should parse a Rails 2.2 request properly" do
    @log_parser.should_not_receive(:warn)
    @log_parser.parse_file(log_fixture(:rails_22)) do |request|
      request.should =~ :processing
      request.should =~ :completed  
    
      request[:controller].should == 'PageController'
      request[:action].should     == 'demo'
      request[:url].should        == 'http://www.example.coml/demo'    
      request[:status].should     == 200
      request[:duration].should   == 0.614
      request[:db].should         == 0.031
      request[:view].should       == 0.120
    end
  end
  
  it "should parse a syslog file with prefix correctly" do
    @log_parser.should_not_receive(:warn)    
    @log_parser.parse_file(log_fixture(:syslog_1x)) do |request| 
      
      request.should be_completed
      
      request[:controller].should == 'EmployeeController'
      request[:action].should     == 'index'
      request[:url].should        == 'http://example.com/employee.xml'    
      request[:status].should     == 200
      request[:duration].should   == 0.21665
      request[:db].should         == 0.0
      request[:view].should       == 0.00926
    end
  end
  
  it "should parse cached requests" do
    @log_parser.should_not_receive(:warn)
    @log_parser.parse_file(log_fixture(:rails_22_cached)) do |request| 
      request.should be_completed
      request =~ :cache_hit
    end  
  end
  
  it "should detect unordered requests in the logs" do
    @log_parser.should_not_receive(:handle_request)
    # the first Processing-line will not give a warning, but the next one will
    @log_parser.should_receive(:warn).with(:unclosed_request, anything).once
    # Both Completed ;ines will give a warning
    @log_parser.should_receive(:warn).with(:no_current_request, anything).twice
    @log_parser.parse_file(log_fixture(:rails_unordered))
  end  
end