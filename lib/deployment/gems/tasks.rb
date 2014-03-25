require 'rake'
require 'rake/tasklib'
require_relative 'vendorizor'

module Deployment
  module Gems
    class Tasks < ::Rake::TaskLib
      include ::Rake::DSL
      def initialize(target_directory)
        namespace :gems do
          desc 'Vendorize dependencies'
          task :vendorize do
            Vendorizor.new(target_directory).vendorize
          end

          desc 'Remove vendorized dependencies'
          task :clean do
            if Dir.exists?(target_directory)
              FileUtils.rm_r(target_directory)
            end
          end
        end
      end
    end
  end
end
