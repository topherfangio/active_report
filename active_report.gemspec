# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{active_report}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Topher Fangio"]
  s.date = %q{2009-06-18}
  s.email = %q{fangiotophia@gmail.com}
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "MIT-LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "generators/active_report/USAGE",
     "generators/active_report/active_report_generator.rb",
     "generators/active_report/templates/controller.rb",
     "generators/active_report/templates/create.html.erb",
     "generators/active_report/templates/model.rb",
     "generators/active_report/templates/new.html.erb",
     "generators/active_reports_controller/USAGE",
     "generators/active_reports_controller/active_reports_controller_generator.rb",
     "generators/active_reports_controller/templates/active_reports_controller.rb",
     "lib/active_report.rb",
     "lib/active_report/base.rb",
     "lib/active_report/core_extention.rb",
     "lib/active_report/errors.rb",
     "lib/active_report/validations.rb",
     "tasks/active_report_tasks.rake",
     "test/active_report_test.rb",
     "test/core_extention_test.rb",
     "test/test_helper.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/topherfangio/active_report}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{ActiveReport enables you to easily generate reports.}
  s.test_files = [
    "test/test_helper.rb",
     "test/core_extention_test.rb",
     "test/active_report_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
