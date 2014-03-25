require 'rake'
require 'rake/tasklib'

module Deployment
  module Homebrew
    class Tasks < ::Rake::TaskLib
      include ::Rake::DSL

      def initialize(name, version, git_url, homebrew_dir, gh_pages_dir)
        namespace :homebrew do
          desc 'Generate homebrew formula and add it to the repo'
          task :build => ['checkout', 'formula:build', 'commit']

          desc 'Checkout homebrew repo locally'
          task :checkout do
            `git clone #{git_url} #{homebrew_dir}`
          end

          desc 'Check in the new Homebrew formula'
          task :commit do
            Dir.chdir(homebrew_dir) do
              `git add Formula/#{name.downcase}.rb`
              `git commit -m "#{name}: Release version #{version}"`
            end
          end

          desc 'Push homebrew repo'
          task :push do
            Dir.chdir(homebrew_dir) do
              `git push`
            end
          end

          desc 'Remove Homebrew repo'
          task :clean do
            if Dir.exists?(homebrew_dir)
              FileUtils.rm_rf(homebrew_dir)
            end
          end

          namespace :formula do
            desc 'Build homebrew formula'
            task :build do
              formula = File.read("homebrew/#{name}.rb")
              formula.gsub!('__VERSION__', version)
              formula.gsub!('__SHA__', `shasum #{gh_pages_dir}/#{name}-#{version}.tar.gz`.split.first)
              File.write("#{homebrew_dir}/Formula/#{name.downcase}.rb", formula)
            end
          end
        end
      end
    end
  end
end
