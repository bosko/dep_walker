$LOAD_PATH.unshift File.expand_path('../', __FILE__) 
require "dep_walker/dep_walker"

module DepWalker
  extend self
  
  VERSION = '1.0.0'

  def check_all
    all_deps = {}
    Gem.source_index.gems.each do |name,spec|
      gem_deps = check(spec)
      all_deps[name] = gem_deps unless gem_deps.empty?
    end
    
    all_deps
  end

  def check(name_or_spec)
    gem_deps = {}
    spec = name_or_spec.is_a?(String) ? Gem.source_index.gems[name_or_spec] : name_or_spec
    walk_deps(spec).each do |k,v|
      gem_deps[k] = v[:not_found] unless v[:not_found].empty?
    end
    gem_deps
  end
  
  def walk_deps(gem_spec)
    dep_tree = {}
    if gem_spec.is_a? Gem::Specification
      dependencies(gem_spec).each do |k,v|
        found = {}
        not_found = []
        v.each do |shlib|
          if found[shlib].nil? || not_found.include?(shlib)
            shlib_dir = find_shlib_dir(File.dirname(k), shlib)
            if shlib_dir
              found[shlib] = shlib_dir
            else
              not_found << shlib unless shlib.start_with? "msvcrt-ruby"
            end
          end
        end
        dep_tree[k] = {:found => found, :not_found => not_found}
      end
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

  private

  def find_shlib_dir(init_path, shlib)
    ENV["PATH"].split(File::PATH_SEPARATOR).unshift(init_path).each do |path|
      return path if File.file?(File.join(path, shlib))
    end
    nil
  end

  def dll_dependencies(dll_path = "")
    return [] unless ['.dll', '.so'].include? File.extname dll_path
    
    raw_dependencies(dll_path).map {|dep| dep.downcase}.uniq
  end
end
