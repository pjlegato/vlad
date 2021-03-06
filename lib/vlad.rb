require 'rubygems'
require 'thread'
require 'rake_remote_task'

$TESTING ||= false

##
# Vlad the Deployer - Pragmatic application deployment automation, without mercy.
#
# Please read doco/getting_started.txt or http://rubyhitsquad.com/
#
# === Basic scenario:
#
# 1. rake vlad:setup   (first time only)
# 2. rake vlad:update
# 3. rake vlad:migrate (optional)
# 4. rake vlad:start

module Vlad

  ##
  # This is the version of Vlad you are running.
  VERSION = '1.2.0.2'

  ##
  # Base error class for all Vlad errors.
  class Error < RuntimeError; end

  ##
  # Raised when you have incorrectly configured Vlad.
  class ConfigurationError < Error; end

  ##
  # Raised when a remote command fails.
  class CommandFailedError < Error; end

  ##
  # Raised when an environment variable hasn't been set.
  class FetchError < Error; end

  ##
  # Loads tasks file +tasks_file+ and various recipe styles as a hash
  # of category/style pairs. Recipes default to:
  #
  #     :app    => :mongrel
  #     :config => 'config/deploy.rb'
  #     :core   => :core
  #     :scm    => :subversion
  #     :web    => :apache
  #
  # You can override individual values and/or set to nil to
  # deactivate. :config will get loaded last to ensure that user
  # variables override default values.
  #
  # And by all means, feel free to skip this entirely if it doesn't
  # fit for you. All it does is a fancy-pants require. Require
  # whatever files you need as you see fit straight from your
  # Rakefile. YAY for simple and clean!
  def self.load options = {}
    options = {:config => options} if String === options

    recipes = {
      :app    => 'merb.god',
      :config => 'config/deploy.rb',
      :core   => :core,
      :scm    => :git,
      :web    => :maintenance,
    }.merge(options)
    
    # be sure core comes first so base tasks aren't clobbered
    if core = recipes.delete(:core)
      require "vlad/#{core}"
    end
    recipes.each do |flavor, recipe|
      next if recipe.nil? or flavor == :config
      require "vlad/#{recipe}"
    end

    Kernel.load recipes[:config]
  end
end

class String #:nodoc:
  def cleanup
    if ENV['FULL'] then
      gsub(/\s+/, ' ').strip
    else
      self[/\A.*?\./]
    end
  end
end
