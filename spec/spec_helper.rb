$: << File.join(File.dirname(__FILE__), '..', 'lib')

require 'rubygems'
require 'spec'
require 'request_log_analyzer'

module RequestLogAnalyzerSpecHelper
  
  def format_file(format)
    File.dirname(__FILE__) + "/file_formats/#{format}.rb"
  end
  
  def spec_format
    @spec_format ||= begin
      require format_file(:spec_format)
      SpecFormat.new
    end
  end
      
  def log_fixture(name)
    File.dirname(__FILE__) + "/fixtures/#{name}.log"
  end
  
  def request(fields, format = TestFileFormat)
    if fields.kind_of?(Array)
      RequestLogAnalyzer::Request.create(format, *fields)
    else
      RequestLogAnalyzer::Request.create(format, fields)
    end
  end
  
end

module TestFileFormat
  
  module Summarizer
    def self.included(base)
      # monkey patching for summarizer here :-)
    end
  end
  
  module LogParser
    def self.included(base)
      # monkey patching for log parser here :-)
    end
  end
  
  LINE_DEFINITIONS = {
    :first => {
      :header => true,
      :teaser => /processing /,
      :regexp => /processing request (\d+)/,
      :captures => [{ :name => :request_no, :type => :integer, :anonymize => :slightly }]    
    },
    :test => {
      :teaser => /testing /,
      :regexp => /testing is (\w+)/,
      :captures => [{ :name => :test_capture, :type => :string, :anonymize => true}]
    }, 
    :last => {
      :footer => true,
      :teaser => /finishing /,
      :regexp => /finishing request (\d+)/,
      :captures => [{ :name => :request_no, :type => :integer}]
    }
  }
end
