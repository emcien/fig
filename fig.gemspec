Gem::Specification.new do |s|
  s.name = "emcien-fig"
  s.version = "1.0"
  s.date = "2015-05-06"
  s.authors = ["Emcien Engineering"]
  s.summary = "fig is an extracted configuration object for ruby"
  s.files = %w(lib/fig.rb)
  s.require_paths = ["lib"]

  s.add_dependency "figaro", "~> 1.0.0"

  s.add_development_dependency "rspec", "~> 2.14.1"
  s.add_development_dependency "rubocop"
  s.add_development_dependency "overcommit"
  s.add_development_dependency "pry"
end
