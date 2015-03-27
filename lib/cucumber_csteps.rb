require 'cucumber_csteps/version'
require 'cucumber_csteps/parser'
require 'cucumber_csteps/define_steps'

module CucumberCsteps
  def self.include_path
    File.expand_path(File.join(__FILE__, '..', 'include'))
  end
end
