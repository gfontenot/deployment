require_relative 'gems/tasks'
require_relative 'tarball/tasks'
require_relative 'homebrew/tasks'

module Deployment
  class Release < ::Rake::TaskLib
    include ::Rake::DSL

    attr_writer :name,
      :version,
      :gem_directory,
      :git,
      :homebrew_directory,
      :homebrew_git,
      :gh_pages_dir,
      :package

    def initialize
      yield self

      namespace :deployment do
        release_tasks
        Gems::Tasks.new(@gem_directory)
        Tarball::Tasks.new(@name, @version, @git, @gh_pages_dir, @package)
        Homebrew::Tasks.new(@name, @version, @homebrew_git, @homebrew_dir, @gh_pages_dir)
      end
    end

    def release_tasks
      desc 'Push new release'
      task :release => ['release:build', 'release:push', 'release:clean']

      namespace :release do
        desc 'Build a new release'
        task :build => ['tarball:build', 'homebrew:build']

        desc 'Push sub-repositories'
        task :push => ['tarball:push', 'homebrew:push']

        desc 'Clean all build artifacts'
        task :clean => ['gems:clean', 'tarball:clean', 'homebrew:clean']
        end
    end
  end
end
