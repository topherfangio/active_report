Array.class_eval do
  
  def count
    size # Temporary fix because I can't upgrade the version of ruby on wildcat
  end
  
  alias_method :add, :<<
end unless Array.new.respond_to? :add

Object.class_eval do
  def self.alias_class_method(new_name, old_name)
    meta = class << self; self; end
    meta.send :alias_method, new_name, old_name
  end
end unless Object.respond_to? :alias_class_method