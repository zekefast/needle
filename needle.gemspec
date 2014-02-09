require './lib/needle/version'

Gem::Specification.new do |s|

   s.name = 'needle'
   s.version = Needle::Version::STRING
   s.platform = Gem::Platform::RUBY
   s.summary = %q{Needle is a Dependency Injection/Inversion of Control container for Ruby. It supports both type-2 (setter) and type-3 (constructor) injection. It takes advantage of the dynamic nature of Ruby to provide a rich and flexible approach to injecting dependencies.}
   s.files = Dir.glob("{benchmarks,doc,examples,lib,test}/**/*").delete_if { |item| item.include?( "CVS" ) }
   s.files.concat [ "LICENSE", "Rakefile", "NEWS" ]
   s.require_path = 'lib'
   s.autorequire = 'needle'

   s.has_rdoc=true
   s.extra_rdoc_files = [ 'doc/README' ]
   s.rdoc_options << '--title' << 'Needle -- Dependency Injection for Ruby' << 
    '--main' << 'doc/README'

   s.test_suite_file = 'test/ALL-TESTS.rb'

   s.author = "Jamis Buck"
   s.email = "jamis@37signals.com"
   s.homepage = "http://needle.rubyforge.org"

end
