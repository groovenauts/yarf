require 'yarf'

module Yarf
  class ModelConfig

    attr_reader :model_class, :name, :ignored_columns, :dependencies
    def initialize(model_class, hash)
      @model_class = model_class
      @name = model_class.name
      @skip = !!hash["skip"]
      @ignored_columns = hash["ignored_columns"] || []
      @dependencies = hash["dependencies"] || []
    end

    def skip?
      @skip
    end

    def target?
      not(skip?) and not(@model_class.abstract_class?)
    end

    def selected_columns
      @selected_columns ||= model_class.columns.reject{|c| ignored_columns.include?(c.name)}
    end

    def delete_all
      # puts "deleting #{name}"
      model_class.delete_all
    end

    def destroy_all
      puts "destroying #{name}"
      model_class.destroy_all
    end

    def load_fixtures(fixtures_dir)
      puts model_class.all.map(&:inspect)
      [:create, :save].each{|a| model_class.skip_callback(a)}
      path = File.join(fixtures_dir, name.underscore + ".yml")
      unless File.readable?(path)
        Rails.logger.warn("fixture #{path} not found for #{name}")
        return
      end
      begin
        rows = YAML.load_file(path)
        rows.each do |row|
          model_class.connection.insert_fixture(row, model_class.table_name)
        end
      ensure
        [:create, :save].each{|a| model_class.set_callback(a)}
      end
    end
  end
end
