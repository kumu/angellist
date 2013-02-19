module Experience
  # used to automatically determine the correct locations for
  # installing locally and releasing
  def self.namespace
    "angellist"
  end

  class Engine < ::Rails::Engine
    isolate_namespace Experience
  end
end