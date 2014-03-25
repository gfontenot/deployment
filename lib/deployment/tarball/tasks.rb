require 'rake'
require 'rake/tasklib'
require 'rake/packagetask'

module Deployment
  module Tarball
    class Tasks < ::Rake::TaskLib
      include ::Rake::DSL

      def initialize(name, version, git_url, gh_pages_dir, package_block)
        namespace :tarball do
          desc 'Build the tarball'
          task :build => ['checkout', 'package', 'move', 'commit']

          desc 'Checkout gh-pages'
          task :checkout do
            `git clone --branch gh-pages #{git_url} #{gh_pages_dir}`
          end

          desc 'Move tarball into gh-pages'
          task :move do
            FileUtils.mv("pkg/#{name}-#{version}.tar.gz", gh_pages_dir)
          end

          desc 'Check in the new tarball'
          task :commit do
            Dir.chdir(gh_pages_dir) do
              `git add #{name}-#{version}.tar.gz`
              `git commit -m "Release version #{version}"`
            end
          end

          desc 'Push the gh-pages branch'
          task :push do
            Dir.chdir(gh_pages_dir) do
              `git push`
            end
          end

          desc 'Remove gh-pages and pkg directories'
          task :clean do
            if Dir.exists?(gh_pages_dir)
              FileUtils.rm_rf(gh_pages_dir)
            end

            if Dir.exists?('pkg')
              FileUtils.rm_rf('pkg')
            end
          end

          Rake::PackageTask.new(name, version, &package_block)
        end
      end
    end
  end
end
