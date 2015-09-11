require "yarf/version"

# Yarf means "Yet Another Rails Fixture"
module Yarf
  autoload :Config     , "yarf/config"
  autoload :ModelConfig, "yarf/model_config"
  autoload :Dumper     , "yarf/dumper"
  autoload :Recorder   , "yarf/recorder"

  class << self
    def instance
      @instance ||= Config.load_file(File.expand_path("../../spec/fixtures/config.yml", __FILE__))
    end
    def record(name)
      instance.record(name)
    end
    def run_scenarios(*args)
      instance.run_scenarios(*args)
    end
    def load_fixtures(*args)
      instance.load_fixtures(*args)
    end
  end
end
