ENV['RAILS_ENV'] = 'test'
ENV['RAILS_ROOT'] ||= File.dirname(__FILE__) + '../../../../..'

require 'rubygems'
require 'active_support'
require 'active_support/test_case'

require 'test/unit'

require 'active_report'

class SimpleTestReport < ActiveReport::Base
  def build_report
    entries.add(ActiveReport::HashEntry.new( :first_name => "Topher", :last_name => "Fangio" ))
  end
end

class BasicTestReport < ActiveReport::Base
  define_attribute :jobNumber
  validates_presence_of :jobNumber
  
  def build_report
    entries.add(ActiveReport::HashEntry.new( :jobNumber => @jobNumber ))
  end
end