module ActiveReport
  
  # Error class that allows the use of +f.error_messages+ inside a
  # +form_for+ block.
  class Errors < Array
    def full_messages
      self
    end
  end
  
end