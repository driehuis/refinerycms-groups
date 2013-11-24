# Encoding: UTF-8

Gem::Specification.new do |s|
  s.platform          = Gem::Platform::RUBY
  s.name              = 'refinerycms-groups'
  s.authors           = ['Lizhe', 'Gilles Crofils']
  s.version           = '2.1.0'
  s.description       = 'Ruby on Rails Groups extension for Refinery CMS'
  s.date              = '2013-11-22'
  s.summary           = 'Groups extension for Refinery CMS'
  s.require_paths     = %w(lib)
  s.files             = Dir["{app,config,db,lib}/**/*"] + ["readme.md"]

  # Runtime dependencies
  s.add_dependency             'refinerycms',         '~> 2.1.0'
  s.add_dependency             'acts_as_indexed'
  s.add_dependency             'haml'

  # Development dependencies (usually used for testing)
  s.add_development_dependency 'refinerycms-testing', '~> 2.1.0'
end
