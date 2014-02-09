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

require 'needle'
require 'calc'

reg = Needle::Registry.new
Calculator.register_services( reg )

reg.calc.define! do
  intercept( :calculator ).
    with! { logging_interceptor }.
    with_options( :exclude=>%w{divide multiply add} )

  $add_count = 0
  operations.intercept( :add ).
    doing do |chain,ctx|
      $add_count += 1
      chain.process_next( ctx )
    end
end

calc = reg.calc.calculator

puts "add(8,5):      #{calc.add( 8, 5 )}"
puts "subtract(8,5): #{calc.subtract( 8, 5 )}"
puts "multiply(8,5): #{calc.multiply( 8, 5 )}"
puts "divide(8,5):   #{calc.divide( 8, 5 )}"
puts "sin(pi/3):     #{calc.sin( Math::PI/3 )}"
puts "add(1,-6):     #{calc.add( 1, -6 )}"

puts
puts "'add' invoked #{$add_count} times"
