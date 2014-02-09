$:.unshift "../../lib"
require 'needle'

VALUES = { :hello => "world", :bye => "cruel world" }

reg = Needle::Registry.new do |reg|
  require 'refreshable'
  register_refreshable_model( reg )

  reg.define! do
    c1( :model=>:refreshable ) { Struct.new( :value ).new( VALUES[:hello] ) }
    c2( :model=>:refreshable ) { Struct.new( :value ).new( VALUES[:bye] ) }
    c3( :model=>:refreshable, :observe=>[c1] ) { Struct.new( :bob ).new( c1.value ) }
    c4( :model=>:refreshable, :observe=>[c2, c3] ) { Struct.new( :fred, :jim ).new( c3.bob, c2.value ) }
  end
end

def dump
  puts "  c1: #{$a.value.inspect}"
  puts "  c2: #{$b.value.inspect}"
  puts "  c3: #{$c.bob.inspect}"
  puts "  c4:"
  puts "    fred: #{$d.fred.inspect}"
  puts "    jim : #{$d.jim.inspect}"
end

puts "First, get c1, c2, c3, and c4..."
puts "(VALUES is #{VALUES.inspect})"
$a = reg.c1
$b = reg.c2
$c = reg.c3
$d = reg.c4

dump

puts
puts "Now, we change VALUES..."
VALUES[:hello] = "jisang"
puts "(VALUES is #{VALUES.inspect})"
puts "Notice that c1, c2, c3, and c4 are unchanged..."
dump

puts
puts "However, if we refresh c1..."
$a.refresh!
puts "The values in c1, c2, c3, and c4 have been updated! But c4.jim remains the same."
dump

puts
puts "Now, we refresh c2 (Only used by c4)..."
VALUES[:hello] = "this won't be seen"
VALUES[:bye] = "friendly world!"
$b.refresh!
dump
