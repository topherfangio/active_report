class ActiveReportGenerator < Rails::Generator::NamedBase
  attr_reader :root
  
  def manifest
    root = "."
    @root = File.expand_path(File.directory?(root) ? root : File.join(Dir.pwd, root))
    
    record do |m|
      m.template 'controller.rb', "app/controllers/#{file_name.pluralize}_controller.rb"
      m.template 'model.rb', "app/models/#{file_name}.rb"
      
      m.directory "app/views/#{file_name.pluralize}"
      m.template 'create.html.erb', "app/views/#{file_name.pluralize}/create.html.erb"
      m.template 'new.html.erb', "app/views/#{file_name.pluralize}/new.html.erb"
      
      m.route_resources file_name.pluralize
    end
  end
  
end
