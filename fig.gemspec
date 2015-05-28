Gem::Specification.new do |s|
  s.name = "fig"
  s.version = "1.0"
  s.date = "2015-05-06"
  s.authors = ["Emcien Engineering"]
  s.summary = "fig is an extracted configuration object for patterns"
  s.files = %w(lib/fig.rb)
  s.require_paths = ["lib"]

  s.add_dependency "figaro", "~> 1.0.0"

  s.add_development_dependency "rspec", "~> 2.14.1"
end
