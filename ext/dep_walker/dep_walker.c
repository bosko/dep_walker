#include <ruby.h>
#include "win.h"

static VALUE raw_dependencies(VALUE self, VALUE path)
{
  VALUE mDeps = rb_ary_new();
  if (RSTRING_LEN(path) > 0)
  {
    DumpDllFromPath(mDeps, StringValuePtr(path));
  }
  return mDeps;
}

void Init_dep_walker()
{
  VALUE mDepWalker = rb_define_module("DepWalker");
  rb_define_singleton_method(mDepWalker, "raw_dependencies", raw_dependencies, 1);
}
