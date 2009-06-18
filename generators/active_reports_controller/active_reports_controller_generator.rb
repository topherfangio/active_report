class ActiveReportsControllerGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.file 'active_reports_controller.rb', "app/controllers/active_reports_controller.rb"
    end
  end
end
