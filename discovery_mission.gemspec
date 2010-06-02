Gem::Specification.new do |s| 
  s.name = 'discovery-mission'
  s.version = "0.0.1"
  s.platform = Gem::Platform::RUBY
  s.summary = "A simple website crawler"
  s.description = "Discovery Mission is an easy-to-use website crawler. Use it for generating sitemaps."
  s.files = `git ls-files`.split("\n").sort
  s.test_files = ['spec.rb']
  s.require_path = '.'
  s.author = "Mickael Riga"
  s.email = "mig@mypeplum.com"
  s.homepage = "http://github.com/mig-hub/discovery_mission"
end