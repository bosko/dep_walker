$LOAD_PATH.unshift File.expand_path('../', __FILE__)
require 'rubygems'
require "dep_walker/dep_walker"

def green(string)
  if $options.color
    "\e[1;32m#{string}\e[0m"
  else
    string
  end
end

def red(string)
  if $options.color
    "\e[1;31m#{string}\e[0m"
  else
    string
  end
end

def trace(message, level=TRACE_INFO)
  return unless $options.trace
  
  case level
  when DepWalker::TRACE_INFO
    puts message
  when DepWalker::TRACE_SUCCESS
    puts green(message)
  when DepWalker::TRACE_ERROR
    puts red(message)
  end
end

module DepWalker
  extend self
  
  VERSION = '1.0.0'

  TRACE_INFO = 0
  TRACE_SUCCESS = 1
  TRACE_ERROR = 2

  def check_all
    all_deps = {}
    Gem::Specification.find_all.each do |spec|
      gem_deps = check(spec)
      all_deps[spec.full_name] = gem_deps unless gem_deps.empty?
    end
    
    all_deps
  end

  def check(name_or_spec, version=nil)
    gem_deps = {}
    spec = name_or_spec.is_a?(String) ? Gem::Specification.find_by_name(name_or_spec, :version=>version) : name_or_spec
    walk_deps(spec).each do |k,v|
      gem_deps[k] = v[:not_found] unless v[:not_found].empty?
    end
    gem_deps
  end
  
  def walk_deps(gem_spec)
    dep_tree = {}
    if gem_spec.is_a? Gem::Specification
      trace("Checking #{gem_spec.full_name}", TRACE_INFO)
      dependencies(gem_spec).each do |k,v|
        trace("  #{k}", TRACE_INFO)
        found = {}
        not_found = []
        v.each do |shlib|
          if found[shlib].nil? || not_found.include?(shlib)
            shlib_dir = find_shlib_dir(File.dirname(k), shlib)
            if shlib_dir
              found[shlib] = shlib_dir
              trace("    #{shlib} -> Found at #{shlib_dir}", TRACE_SUCCESS)
            elsif !shlib.start_with?("msvcrt-ruby")
              not_found << shlib
              trace("    #{shlib} -> Not found", TRACE_ERROR)
            end
          end
        end
        dep_tree[k] = {:found => found, :not_found => not_found}
      end
      trace("="*40, TRACE_INFO)
    end
    dep_tree
  end

  def dependencies(gem_spec)
    deps = {}
    Dir.glob(File.join(gem_spec.full_gem_path, "**/*")).select do |f|
      f if [".so",".dll"].include? File.extname(f)
    end.each do |ext|
      deps[ext] = dll_dependencies(ext)
    end
    deps
  end

  def dll_dependencies(dll_path = "")
    return [] unless ['.dll', '.so'].include? File.extname dll_path
    
    raw_dependencies(dll_path).map {|dep| dep.downcase}.uniq
  end

  private

  def find_shlib_dir(init_path, shlib)
    ENV["PATH"].split(File::PATH_SEPARATOR).unshift(init_path).each do |path|
      return path if File.file?(File.join(path, shlib))
    end
    nil
  end
end
