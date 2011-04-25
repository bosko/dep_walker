require "mkmf"

unless find_header('imagehlp.h')
  abort "header imagehlp.h is missing"
end

unless find_library('imagehlp', 'LoadImage')
  abort "library imagehlp is missing"
end

create_makefile('dep_walker/dep_walker')
