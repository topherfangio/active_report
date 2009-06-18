module ActiveReport
  
  module Validations
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods

      # Ensures that the requested parameters exist and are not empty.
      #
      #   class TestReport < ActiveReport::Base
      #     validates_presence_of :jobNumber
      #   end
      def validates_presence_of(*params)
        return if params.nil?
        
        send(:validate) do |report|
          params.each do |param|
            field = report.params[param.to_s]
              
            if field.blank?
              report.errors.add "#{param} must be defined"
            end
          end
        end
      end
      
    end # Module ClassMethods   
    
  end # Module Validations
  
end # Module ActiveReport