require 'yarf'
require 'tsort'

module Yarf
  class Config

    class << self
      def load_file(path)
        new(YAML.load_file_with_erb(path))
      end
    end

    attr_reader :base_dir
    attr_reader :model_configs
    def initialize(hash)
      @base_dir = File.expand_path(hash["base_dir"] || 'spec/fixtures')
      @models_paths = hash["app_models_paths"] || defined?(Rails) ? Rails.root.join("app/models").to_s : raise("no app_models_paths found")
      @model_configs = load_model_configs(hash["models"])
    end

    def load_model_configs(hash)
      common_mc = hash.delete("common") || {}
      unloaded = hash.keys
      class_names = @models_paths.map do |path|
        Dir.chdir(path) do
          ignores = File.readable?(".yarfignore") ? File.read(".yarfignore").lines.map(&:strip) : []
          Dir.glob('**/*.rb').
            # reject app/models/concerns to avoid "Circular dependency detected while autoloading constant Concerns::Traceable"
            reject{|path| ignores.any?{|ig| path =~ /\A#{Regexp.escape(ig)}/} }.
            map{|s| s.sub(/\.rb\z/,'').camelize }
        end
      end
      class_names.flatten!
      model_classes = class_names.map(&:constantize).select{|c| c < ActiveRecord::Base }
      configs = model_classes.map do |model_class|
        mc = common_mc.dup.update(hash[model_class.name] || {})
        unloaded.delete(model_class.name)
        ModelConfig.new(model_class, mc)
      end
      configs += unloaded.map do |class_name|
        mc = common_mc.dup.update(hash[class_name] || {})
        klass = class_name.constantize
        ModelConfig.new(klass, mc)
      end
      tsort(configs)
    end

    def tsort(configs)
      sources = configs.each_with_object({}){|c,d| d[c.name] = c}
      deps = configs.each_with_object({}) do |c,d|
        d[c.name] = c.model_class.reflections.values.
                    select{|r| r.macro == :belongs_to }.
                    map{|r| r.polymorphic? ? nil : r.klass.name }.compact
        if c.dependencies
          d[c.name] += c.dependencies
        end
      end
      deps.singleton_class.module_eval do
        include TSort
        alias tsort_each_node each_key
        def tsort_each_child(node, &block)
          fetch(node).each(&block)
        end
      end
      deps.tsort.map{|name| sources[name]}
    end

    def recorder
      @recorder ||= Recorder.new(self)
    end
    def dumper
      @dumper ||= Dumper.new(self)
    end

    def target_model_configs
      model_configs.select(&:target?)
    end
    def skipped_model_configs
      model_configs.select(&:skip?)
    end

    def target_model_names
      target_model_configs.map(&:name)
    end
    def skipped_model_names
      skipped_model_configs.map(&:name)
    end

    def delete_targets
      target_model_configs.reverse.each(&:delete_all)
    end

    def destroy_targets
      target_model_configs.reverse.each(&:destroy_all)
    end

    def record(name)
      recorder.dump(name)
    end

    def run_scenarios(*args)
      args.each do |path|
        puts "executing ... #{path}"
        load(path)
      end
    end

    def load_fixtures(fixtures_dir)
      delete_targets
      dir = File.join(base_dir, fixtures_dir)
      target_model_configs.each{ |mc| mc.load_fixtures(dir) }
    end

  end
end
