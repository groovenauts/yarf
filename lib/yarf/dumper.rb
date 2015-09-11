require 'yarf'
require 'fileutils'

module Yarf
  class Dumper

    attr_reader :config
    def initialize(config)
      @config = config
    end

    def dump(dest_dir)
      config.target_model_configs.each do |mc|
        columns = mc.selected_columns.map(&:name)
        rows = mc.model_class.connection.select("select * from #{mc.model_class.table_name}").to_hash.map do |r|
          columns.each_with_object({}){|c,d| d[c] = r[c]}
        end
        path = File.expand_path(mc.name.underscore + ".yml", dest_dir)
        FileUtils.mkdir_p(File.dirname(path))
        open(path, "w"){|f| f.puts(YAML.dump(rows))}
      end
    end
  end
end
