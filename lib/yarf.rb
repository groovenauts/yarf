require "yarf/version"

# Yarf means "Yet Another Rails Fixture"
module Yarf
  autoload :Config     , "yarf/config"
  autoload :ModelConfig, "yarf/model_config"
  autoload :Dumper     , "yarf/dumper"
  autoload :Recorder   , "yarf/recorder"

  class << self
    attr_writer :config_path
    def config_path
      @config_path ||= Dir.glob("**/spec/fixtures/config.yml").first
    end
    def instance
      @instance ||= Config.load_file(config_path)
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
