# ActiveReport
require 'active_report/core_extention'

require 'active_report/errors'
require 'active_report/validations'

require 'active_report/base'

%w{ controllers }.each do |dir|
  path = File.join(File.dirname(__FILE__), 'app', dir)
  
  $LOAD_PATH << path
  ActiveSupport::Dependencies.load_paths << path
  ActiveSupport::Dependencies.load_once_paths.delete(path)
end
