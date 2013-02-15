$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
# require "experience/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "experience"
  s.version     = "0.0.1"
  s.authors     = ["Ryan Mohr"]
  s.email       = ["ryan@kumupowered.com"]
  s.homepage    = ""
  s.summary     = "The AngelList Experience, Powered by Kumu"
  s.description = ""

  s.files = Dir["{app,lib}/**/*"] + ["LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]
end
