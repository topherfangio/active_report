module ActiveReport
  
  # Special form of a hash that responds to methods if the method is a key in
  # the entry. Also allows passing a hash as the argement to +new+ to allow for
  # initialization of the +HashEntry+.
  #
  # *Note*: This means you should not have keys whose name is the name of an
  # existing +Hash+ method.
  class HashEntry < Hash
    def initialize(hash = nil)
      super
      
      self.update(hash) unless has.nil?
    end
    
    def method_missing(symbol, *args, &block)
      if self[symbol]
        self[symbol]
      else
        super
      end
    end
    
    def respond_to?(symbol, include_private = false)
      if self[symbol]
        true
      else
        super
      end
    end
    
  end # Class HashEntry
  
  # An Entry class designed to store the sign on the entry for easier
  # manipulation of the stored object.
  class SignedEntry
    attr_accessor :object, :sign
    
    # Creates a new SignedEntry. The sign parameter defaults to
    # <tt>:positive</tt> but accepts any object. If one of the following
    # values are entered for the sign, the sign is automatically
    # converted to a <tt>1</tt> or <tt>-1</tt> depending upon the value
    # entered.
    #
    # * <tt>true</tt>
    # * <tt>false</tt>
    # * <tt>:true, :positive</tt>
    # * <tt>:false, :negative</tt>
    # * <tt>"true", "positive"</tt>
    # * <tt>"false", "negative"</tt>
    def initialize(object = nil, sign = :positive)
      @object = object
      
      @sign = case
        when sign.to_s.eql?("true") then 1
        when sign.to_s.eql?("false") then -1
        when sign.to_s.eql?("positive") then 1
        when sign.to_s.eql?("negative") then -1
        else sign
      end
    end
    
    # Returns true if the sign is greater than or equal to 0.
    #
    # This method is aliased as credit?.
    def positive?
      @sign >= 0
    end
    
    alias_method :credit?, :positive?
    
    # Returns true if the sign is less than 0.
    #
    # This method is aliased as debit?.
    def negative?
      @sign < 0
    end
    
    alias_method :debit?, :negative?
  end # Class SignedEntry

  
  # Active Report objects define how to build a particular report and all required
  # information. Unlike Active Record objects, Active Reports are not saved to nor
  # retrieved from a database, but rather aggregate data from existing Active Record
  # objects (or any other means required).
  #
  # == Creation
  #
  # Active Reports offer many helper methods to assist in creation. For instance, you
  # can specify any number of attributes with the define_attributes method. These
  # attributes will be available to the rest of the class and will be populated with 
  # any values that were passed to the +new+ method.
  #
  #   class JobReport < ActiveReport::Base
  #     define_attribute :jobNumber
  #
  #     validates_presence_of :jobNumber
  #     
  #     def build_report
  #       entries = Job.find_all_by_jobNumber(self.jobNumber)
  #     end
  #   end
  #   
  # Alternatively, you could use an ActiveReport::HashEntry or simple +Hash+.
  #   
  #   class TestReport < ActiveReport::Base
  #     def build_report
  #       (1..5).each { |i| entries.add(ActiveReport::HashEntry.new( :i => i, :name => 'Topher' )) }
  #     end
  #   end
  #   
  #   class TestReport < ActiveReport::Base
  #     def build_report
  #       (1..5).each { |i| entries.add({ :i => i, :name => 'Topher' }) }
  #     end
  #   end
  #
  # == Reporting
  #
  # Generating reports is incredibly easy. The following example shows basic usage
  # assuming that +Job+ is a class extending +ActiveRecord::Base+.
  #
  #   Job.create( :id => 1, :jobNumber => 123456, :company => "Apple Inc." )
  #   Job.create( :id => 2, :jobNumber => 123456, :company => "37signals" )
  #
  #   params = {}
  #   params[:jobNumber] = 123456
  #
  #   report = JobReport.new(params)
  #
  #   if report.generate
  #     report.entries.each { |e| puts "#{e.id}: Job ##{e.jobNumber} for #{e.company}" }
  #   end
  #
  #   # => 1: Job #123456 for Apple Inc.
  #        2: Job #123456 for 37signals
  class Base
    include Enumerable
    include ActiveSupport::Callbacks
    include ActiveReport::Validations
    
    define_callbacks :before_initialize, :after_initialize
    define_callbacks :before_build_report, :after_build_report
    define_callbacks :before_validate, :validate, :after_validate
    
    attr_accessor :id, :params, :errors, :entries
    
    # Sets up all parameters including mulit-parameters-attributes. Sets the id of the
    # report to be the current +Time+ as an integer of the +strftime+ format
    # +"%Y%m%d%H%M%S"+.
    def initialize(params = {})
      @params = setup_parameters(params)
      
      run_callbacks(:before_initialize)
      
      @id = Time.now.strftime("%Y%m%d%H%M%S").to_i
      
      @errors = ActiveReport::Errors.new
      @entries = []
      
      run_callbacks(:after_initialize)
    end
    
    private
    
    def setup_parameters(params = {})
      new_params = {}
      multi_parameter_attributes = []
      
      params.each do |k,v|
        if k.to_s.include?("(")
          multi_parameter_attributes << [ k.to_s, v ]
        else
          new_params[k.to_s] = v
        end
      end
      
      new_params.merge(assign_multiparameter_attributes(multi_parameter_attributes))
    end
    
    # Very simplified version of the ActiveRecord::Base method that handles only dates/times
    def execute_callstack_for_multiparameter_attributes(callstack)
      attributes = {}
      
      callstack.each do |name, values|
        
        if values.empty?
          send(name + '=', nil)
        else
          value = case values.size
            when 2 then t = Time.new; Time.local(t.year, t.month, t.day, values[0], values[min], 0, 0)
            when 5 then t = Time.time_with_datetime_fallback(:local, *values)
            when 3 then Date.new(*values)
            else nil
          end
          
          attributes[name.to_s] = value
        end
        
      end
      
      attributes
    end
    
    # Note, the following private methods are copied (almost) directly from ActiveRecord::Base 2.3.3
    
    def assign_multiparameter_attributes(pairs)
      execute_callstack_for_multiparameter_attributes( extract_callstack_for_multiparameter_attributes(pairs) )
    end
    
    def extract_callstack_for_multiparameter_attributes(pairs)
      attributes = { }
      
      for pair in pairs
        multiparameter_name, value = pair
        attribute_name = multiparameter_name.split("(").first
        attributes[attribute_name] = [] unless attributes.include?(attribute_name)
        
        unless value.empty?
          attributes[attribute_name] <<
          [ find_parameter_position(multiparameter_name), type_cast_attribute_value(multiparameter_name, value) ]
        end
      end
      
      attributes.each { |name, values| attributes[name] = values.sort_by{ |v| v.first }.collect { |v| v.last } }
    end
    
    def type_cast_attribute_value(multiparameter_name, value)
      multiparameter_name =~ /\([0-9]*([a-z])\)/ ? value.send("to_" + $1) : value
    end
    
    def find_parameter_position(multiparameter_name)
      multiparameter_name.scan(/\(([0-9]*).*\)/).first.first
    end
    
    public
    
    # Generates the report by calling +build_report+ and runs validation if requested.
    # Calls +before_build_report+ at the beginning and +after_build_report+ at the end
    # and returns the report against which this method was run.
    def generate(perform_validation = true)
      return false if perform_validation and not self.valid?
      
      run_callbacks(:before_build_report)
      send(:build_report) if self.respond_to? :build_report
      run_callbacks(:after_build_report)
      
      self
    end
    
    # Runs +before_validate+, +validate+ and +after_validate+ and returns
    # true if there were no errors, false otherwise.
    def valid?
      run_callbacks(:before_validate)
      
      @errors = ActiveReport::Errors.new
      
      run_callbacks(:validate)
      run_callbacks(:after_validate)
      
      @errors.empty?
    end
    
    # Defined to always return true since no data actually gets saved to the database.
    # This is necessary for the +form_for+ methods in
    # +ActionView::Helpers::FormHelper+ to work properly.
    def new_record?
      true
    end    
    
    # Override this method to allow for exporting to a csv file.
    #
    # Example:
    # 
    #   def to_csv
    #     FasterCSV.generate do |csv|
    #       csv << [ 'Name', 'Date' ]
    #       
    #       @entries.each do |e|
    #         csv << [ e.name, e.created_at ]
    #       end
    #     end
    #   end
    def to_csv
    end
    
    protected
    # Helper method to easily define new attributes. For example, the following
    #
    #   class TestReport < ActiveReport::Base
    #     define_attributes :jobNumber, :jobStage
    #   end
    #
    # is equivalent to
    #
    #   class TestReport < ActiveReport::Base
    #     attr_accessor :jobNumber, :jobStage
    #  
    #     def intialize(params = {})
    #       super
    #
    #       @jobNumber = params["jobNumber"]
    #       @jobStage = params["jobStage"]
    #     end
    #   end
    #
    # Accepts multiple attributes and is also aliased as +define_attribute+.
    def self.define_attributes(*attribs)
      return if attribs.nil?
      
      send(:before_initialize) do |report|
        attribs.each do |attrib|
          report.class.instance_eval "attr_accessor :#{attrib.to_s}"
          
          report.instance_eval("@#{attrib.to_s} = params['#{attrib.to_s}'] unless params.blank?")
        end
      end
    end
    
    class << self
      alias_method :define_attribute, :define_attributes
    end
    
    # Callback run immediately before +build_report+.
    def before_build_report
    end
    
    # Override this to builds the report and all entries.
    def build_report
    end
    
    # Callback run immediately after +build_report+.
    def after_build_report
    end
    
    # Callback run immediately before +validate+.
    def before_validate
    end
    
    # Overwrite this method for validation checks on generation of report
    # and use +Errors.add(message)+ for invalid attributes.
    def validate
    end
    
    # Callback run immediately after +validate+.
    def after_validate
    end
  end # Class Base
  
end # Module ActiveReport