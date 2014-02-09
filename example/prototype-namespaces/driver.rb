#--
# =============================================================================
# Copyright (c) 2004, Jamis Buck (jamis@37signals.com)
# All rights reserved.
#
# This source file is distributed as part of the Needle dependency injection
# library for Ruby. This file (and the library as a whole) may be used only as
# allowed by either the BSD license, or the Ruby license (or, by association
# with the Ruby license, the GPL). See the "doc" subdirectory of the Needle
# distribution for the texts of these licenses.
# -----------------------------------------------------------------------------
# needle website : http://needle.rubyforge.org
# project website: http://rubyforge.org/projects/needle
# =============================================================================
#++

# This example was inspired by an IRC chat with Christian Neukirchen (chris2),
# in which he asked if there was a way to "reuse" a namespace, basically
# treating it like a class to be instantiated, where reusing the namespace
# would allow the the contained services to be reused/inherited, like
# properties of a class.

$:.unshift "../../lib"

require 'needle'

def assert( condition )
  raise RuntimeError, "assertion failed!", caller unless condition
end

registry = Needle::Registry.define! do
  namespace! :template, :model => :prototype do
    foo { Object.new }
    bar { Object.new }
    baz { Object.new }
  end

  copy1 { template }
  copy2 { template }
  copy3 { template }
end

# the "template" is a prototype, instead of the default singleton. This means
# that each time you request it, you get a different instantiation of it:

o1 = registry.template
o2 = registry.template
assert o1.object_id != o2.object_id

# however, "copy1", "copy2", and "copy3" are all singletons (by default). Thus,
# though they are implemented by the "template" namespace, their singleton
# nature will result in the template only being requested once for each of
# them.

o1 = registry.copy1
o2 = registry.copy1
assert o1.object_id == o2.object_id

o1 = registry.copy2
o2 = registry.copy2
assert o1.object_id == o2.object_id

o1 = registry.copy3
o2 = registry.copy3
assert o1.object_id == o2.object_id

# copy1 != copy2 != copy3, since they are each independent singletons,
# implemented by a prototype service.

o1 = registry.copy1
o2 = registry.copy2
o3 = registry.copy3

assert o1.object_id != o2.object_id
assert o1.object_id != o3.object_id
assert o2.object_id != o3.object_id

# because copy1 != copy2 != copy3, they will each have independent
# singleton versions of the services they "inherited" from "template":

o1 = registry.copy1.foo
o2 = registry.copy2.foo
assert o1.object_id != o2.object_id

# however, those singleton services that were inherited are really
# singletons:

o1 = registry.copy1.foo
o2 = registry.copy1.foo
assert o1.object_id == o2.object_id
