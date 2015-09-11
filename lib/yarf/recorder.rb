# coding: utf-8
require 'yarf'
require 'fileutils'

module Yarf
  class Recorder

    attr_accessor :config
    def initialize(config)
      @config = config
      @no = (ENV["NO"] || 0).to_i # @test フィクスチャを作成する際にyarfが使用する番号の初期値
    end
    
    def dump(name)
      name.sub!(/\.rb\z/, '')
      dir = File.expand_path("%03d-%s" % [@no, name], config.base_dir)
      FileUtils.mkdir_p(dir)
      config.dumper.dump(dir)
      @no += 1
    end
  end
end
