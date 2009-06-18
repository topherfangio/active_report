require 'test_helper'

class CoreExtentionTest < ActiveSupport::TestCase
  test "array responds to add" do
    assert Array.new.respond_to? :add
  end
  
  test "object responds to alias_class_method" do
    assert Object.respond_to? :alias_class_method
    
    Object.alias_class_method :aliased_to_s, :to_s
    
    assert Object.respond_to? :aliased_to_s
  end
end
