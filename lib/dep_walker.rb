$LOAD_PATH.unshift File.expand_path('../', __FILE__) 
require "dep_walker/dep_walker"

module DepWalker
  extend self
  
  VERSION = '1.0.0'

  def dependencies(dll_path = "")
    raw_dependencies(dll_path).map {|dep| dep.downcase}
  end
end

