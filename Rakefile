# -*- coding: utf-8 -*-
# -*- ruby -*-

require 'rubygems'
require 'hoe'
require 'rake/extensiontask'

Hoe.spec 'dep_walker' do
  developer('Boško Ivanišević', 'bosko.ivanisevic@gmail.com')
  self.readme_file = 'README.rdoc'
  self.history_file = 'History.rdoc'
  self.extra_rdoc_files = FileList['*.rdoc']
  self.extra_dev_deps << ['rake-compiler', '>= 0']
  self.spec_extras = { :extensions => ["ext/dep_walker/extconf.rb"] }

  Rake::ExtensionTask.new('dep_walker', spec) do |ext|
    ext.lib_dir = File.join('lib', 'dep_walker')
  end
end

Rake::Task[:test].prerequisites << :compile
