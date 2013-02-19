$:.push File.expand_path("../lib", __FILE__)

#
# Make sure to edit Experience.namespace in lib/experience.rb
#
#
# Include the gem as follows:
# gem 'angellist-experience', :path => '../experiences/angellist', :require => 'experience'
#
# The shared require and module name allow us to easily swap experiences within the main app
#
Gem::Specification.new do |s|
  s.name        = "angellist-experience"
  s.version     = "0.0.1"
  s.authors     = ["Ryan Mohr"]
  s.email       = ["ryan@kumupowered.com"]
  s.homepage    = ""
  s.summary     = "The AngelList Experience, Powered by Kumu"
  s.description = ""

  s.files = Dir["{app,lib}/**/*"] + ["LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]
end
