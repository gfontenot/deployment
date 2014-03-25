require 'bundler'

module Deployment
  module Gems
    class Vendorizor
      EX_USAGE = 64

      def initialize(target_directory)
        @target_directory = target_directory
        @setup_path = File.join(@target_directory, 'setup.rb')
      end

      def vendorize
        FileUtils.mkdir_p(@target_directory)
        FileUtils.rm(@setup_path)
        Bundler.definition.specs_for([:dist]).each do |gem|
          unpack(gem)
          add_require(gem)
        end
      end

      def unpack(gem)
        if gem.name != 'bundler'
          system(
            '/usr/bin/env', 'gem', 'unpack',
            '--target', @target_directory,
            '--version', gem.version.to_s,
            gem.name
          )
        end
      end

      def add_require(gem)
        File.open(@setup_path, 'a') do |setup_file|
          gem.require_paths.each do |path|
            setup_file << "$LOAD_PATH.unshift(File.expand_path(%s, __FILE__))\n" % [
              "../#{gem.name}-#{gem.version}/#{path}".inspect
            ]
          end
        end
      end
    end
  end
end
