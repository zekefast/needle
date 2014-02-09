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

$:.unshift "../../lib"

module Calculator

  class Adder
    def compute( a, b )
      a.to_f + b.to_f
    end
  end

  class Subtractor
    def compute( a, b )
      a.to_f - b.to_f
    end
  end

  class Multiplier
    def compute( a, b )
      a.to_f * b.to_f
    end
  end

  class Divider
    def compute( a, b )
      a.to_f / b.to_f
    end
  end

  class Sine
    def compute( a )
      Math.sin( a )
    end
  end

  class Calculator
    def initialize( operations )
      @operations = operations
    end

    def method_missing( op, *args )
      if @operations.has_key?(op)
        @operations[op].compute( *args )
      else
        super
      end
    end

    def respond_to?( op )
      @operations.has_key?(op) or super
    end
  end

  def register_services( registry )
    registry.namespace! :calc do
      namespace! :operations do
        add      { Adder.new      }
        subtract { Subtractor.new }
        multiply { Multiplier.new }
        divide   { Divider.new    }
        sin      { Sine.new       }
      end

      calculator { Calculator.new( operations ) }
    end
  end
  module_function :register_services

end
