require 'test_helper'

class ActiveReportTest < ActiveSupport::TestCase
  test "Errors properly extends Array" do
    assert ActiveReport::Errors.new.respond_to? :add
    assert ActiveReport::Errors.new.respond_to? :full_messages
  end
  
  test "HashEntry propperly extends Hash" do
    entry = ActiveReport::HashEntry.new(:jobNumber => 123)
    
    assert (entry.respond_to? :jobNumber)
    assert entry.jobNumber == 123
  end
  
  test "class can extend base" do
    class TestReport < ActiveReport::Base
    end
  
    t = TestReport.new
  end
  
  test "class can build report" do
    t = SimpleTestReport.new
    t.generate
  end
  
  test "class can call basic functions" do
    params = {}
    params[:jobNumber] = 123456
    
    t = BasicTestReport.new(params)
    t.generate
    
    t.entries.each do |entry|
      assert entry.jobNumber == params[:jobNumber]
    end
  end
end
