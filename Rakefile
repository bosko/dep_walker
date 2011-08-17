# -*- coding: utf-8 -*-
# -*- ruby -*-

require 'rubygems'
require 'hoe'
require 'rake/extensiontask'

Hoe.spec 'dep_walker' do
  developer('Boško Ivanišević', 'bosko.ivanisevic@gmail.com')
  self.url = %q{http://github.com/bosko/dep_walker}
  self.readme_file = 'README.rdoc'
  self.history_file = 'History.rdoc'
  self.extra_rdoc_files = FileList['*.rdoc']
  self.extra_dev_deps << ['rake-compiler', '>= 0']
  self.spec_extras = { :extensions => ["ext/dep_walker/extconf.rb"] }
  self.require_rubygems_version(">= 1.8.0")
  self.post_install_message = %Q{**************************************************

  Thank you for installing #{self.name}-#{self.version}!

  This version of dep_walker only works with versions of rubygems >= 1.8.0
**************************************************}
  
  Rake::ExtensionTask.new('dep_walker', spec) do |ext|
    ext.lib_dir = File.join('lib', 'dep_walker')
  end
end

Rake::Task[:test].prerequisites << :compile
