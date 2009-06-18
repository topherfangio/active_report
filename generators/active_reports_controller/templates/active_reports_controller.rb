class ActiveReportsController < ApplicationController
  
  def new
    @report = eval("#{self.controller_name.singularize.camelize}.new")
    
    respond_to do |format|
      format.html
    end
  end
    
  def create
    model = self.controller_name.singularize.camelize
    
    if params.nil? or params[model.underscore].nil?
      redirect_to :action => :new and return
    end
    
    @report = eval("#{model}.new(params[:#{model.underscore}])")
      
    respond_to do |format|
      if @report.generate
        format.html
        format.xml { render :xml => @report }
        format.csv do
          filename = []
          
          filename << model.underscore
          filename << '-'
          filename << Time.now.strftime("%Y%m%d-%H%M%S")
          filename << '.csv'
          
          csv = @report.to_csv
          
          if csv.present?
            send_data(csv, :filename => filename.join, :type => 'text/csv', :disposition => 'attachment')
          else
            render :text => "This report cannot be exported to a comma separated values (CSV) list."
          end
        end
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @report.errors, :status => :unprocessable_entity }
        format.csv { render :text => 'An error occured when processing the report.' }
      end
    end
  end
  
  def index
    redirect_to :action => :new
  end
end