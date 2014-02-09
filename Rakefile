require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/contrib/sshpublisher'

require "./lib/needle/version"

PACKAGE_NAME = "needle"
PACKAGE_VERSION = Needle::Version::STRING

SOURCE_FILES = FileList.new do |fl|
  [ "benchmarks", "example", "lib", "test" ].each do |dir|
    fl.include "#{dir}/**/*"
  end
  fl.include "Rakefile"
  fl.exclude( /\bCVS\b/ )
end

PACKAGE_FILES = FileList.new do |fl|
  [ "api", "doc" ].each do |dir|
    fl.include "#{dir}/**/*"
  end
  fl.include "NEWS", "LICENSE", "TODO", "#{PACKAGE_NAME}.gemspec", "setup.rb"
  fl.include SOURCE_FILES
  fl.exclude( /\bCVS\b/ )
end

Gem.manage_gems

def can_require( file )
  begin
    require file
    return true
  rescue LoadError
    return false
  end
end

desc "Default task"
task :default => [ :test ]

desc "Build documentation"
task :doc => [ :rdoc, :manual ]

task :rdoc => SOURCE_FILES

desc "Clean generated files"
task :clean do
  rm_rf "pkg"
  rm_rf "api"
  rm_rf "doc/manual-html"
  rm_f  "doc/faq/faq.html"
end

desc "Run the benchmarks"
task :benchmark do
  FileUtils.chdir "benchmarks" do
    Dir["*.rb"].each { |benchmark| ruby benchmark }
  end
end

desc "Run the examples (to make sure they work)"
task :examples do
  Dir["example/**/driver.rb"].each do |driver|
    FileUtils.chdir File.dirname( driver ) do
      ruby File.basename( driver )
      logs = Dir["*.log"]
      rm_f logs unless logs.empty?
    end
  end
end

desc "Generate the manual"
task :manual => [ "doc/manual-html/index.html" ]

file "doc/manual-html/index.html" => [ "doc/manual/manual.yml" ] do
  FileUtils.cd( "doc/manual" ) { ruby "manual.rb ../manual-html" }
end

Rake::TestTask.new do |t|
  t.test_files = [ "test/ALL-TESTS.rb" ]
  t.verbose = true
end

desc "Prepackage warnings and reminders"
task :prepackage do
  unless ENV["OK"] == "yes"
    puts "========================================================="
    puts "Please check that the following files have been updated"
    puts "in preparation for this release:"
    puts
    puts "  NEWS (with latest release notes)"
    puts "  lib/needle/version.rb (with current version number)"
    puts "  doc/manual/manual.yml (with latest manual changes)"
    puts
    puts "  svn copy http://svn.jamisbuck.org/needle/trunk \\"
    puts "           http://svn.jamisbuck.org/needle/tags/v#{Needle::Version::MAJOR}_#{Needle::Version::MINOR}_#{Needle::Version::TINY} \\"
    puts "           -m \"Tagging the #{Needle::Version::STRING} release\""
    puts
    puts "If you are sure these have all been taken care of, re-run"
    puts "rake with 'OK=yes'."
    puts "========================================================="
    puts

    abort
  end
end

desc "Tag the current trunk with the current release version"
task :tag do
  warn "WARNING: this will tag http://svn.jamisbuck.org/needle/trunk using the tag v#{Needle::Version::MAJOR}_#{Needle::Version::MINOR}_#{Needle::Version::TINY}"
  warn "If you do not wish to continue, you have 5 seconds to cancel by pressing CTRL-C..."
  5.times { |i| print "#{5-i} "; $stdout.flush; sleep 1 }
  system "svn copy http://svn.jamisbuck.org/needle/trunk http://svn.jamisbuck.org/needle/tags/v#{Needle::Version::MAJOR}_#{Needle::Version::MINOR}_#{Needle::Version::TINY} -m \"Tagging the #{Needle::Version::STRING} release\""
end

package_name = "#{PACKAGE_NAME}-#{PACKAGE_VERSION}"
package_dir = "pkg"
package_dir_path = "#{package_dir}/#{package_name}"

gz_file = "#{package_name}.tar.gz"
bz2_file = "#{package_name}.tar.bz2"
zip_file = "#{package_name}.zip"
gem_file = "#{package_name}.gem"

task :gzip => SOURCE_FILES + [ :manual, :rdoc, "#{package_dir}/#{gz_file}" ]
task :bzip => SOURCE_FILES + [ :manual, :rdoc, "#{package_dir}/#{bz2_file}" ]
task :zip  => SOURCE_FILES + [ :manual, :rdoc, "#{package_dir}/#{zip_file}" ]
task :gem  => SOURCE_FILES + [ :manual, "#{package_dir}/#{gem_file}" ]

desc "Build all packages"
task :package => [ :prepackage, :test, :gzip, :bzip, :zip, :gem ]

directory package_dir

file package_dir_path do
  mkdir_p package_dir_path rescue nil
  PACKAGE_FILES.each do |fn|
    f = File.join( package_dir_path, fn )
    if File.directory?( fn )
      mkdir_p f unless File.exist?( f )
    else
      dir = File.dirname( f )
      mkdir_p dir unless File.exist?( dir )
      rm_f f
      safe_ln fn, f
    end
  end
end

file "#{package_dir}/#{zip_file}" => package_dir_path do
  rm_f "#{package_dir}/#{zip_file}"
  FileUtils.chdir package_dir do
    sh %{zip -r #{zip_file} #{package_name}}
  end
end

file "#{package_dir}/#{gz_file}" => package_dir_path do
  rm_f "#{package_dir}/#{gz_file}"
  FileUtils.chdir package_dir do
    sh %{tar czvf #{gz_file} #{package_name}}
  end
end

file "#{package_dir}/#{bz2_file}" => package_dir_path do
  rm_f "#{package_dir}/#{bz2_file}"
  FileUtils.chdir package_dir do
    sh %{tar cjvf #{bz2_file} #{package_name}}
  end
end

file "#{package_dir}/#{gem_file}" => package_dir do
  spec = eval(File.read(PACKAGE_NAME+".gemspec"))
  Gem::Builder.new(spec).build
  mv gem_file, "#{package_dir}/#{gem_file}"
end

rdoc_dir = "api"

desc "Build the RDoc API documentation"
task :rdoc => :rdoc_core do
  img_dir = File.join( rdoc_dir, "files", "doc", "images" )
  mkdir_p img_dir
  Dir["doc/images/*"].reject { |i| File.directory?(i) }.each { |f|
    cp f, img_dir
  }
end

Rake::RDocTask.new( :rdoc_core ) do |rdoc|
  rdoc.rdoc_dir = rdoc_dir
  rdoc.title    = "Needle -- Dependency Injection for Ruby"
  rdoc.options << '--line-numbers --inline-source --main doc/README'
  rdoc.rdoc_files.include('doc/README', 'doc/di-in-ruby.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')

  if can_require( "rdoc/generators/template/html/jamis" )
    rdoc.template = "jamis"
  end
end

desc "Build the FAQ document"
task :faq => "doc/faq/faq.html"

file "doc/faq/faq.html" => [ "doc/faq/faq.rb", "doc/faq/faq.yml" ] do
  FileUtils.cd( "doc/faq" ) { ruby "faq.rb > faq.html" }
end

desc "Publish the user's manual"
task :pubman => [ :manual ] do
  Rake::SshDirPublisher.new(
    "minam@rubyforge.org",
    "/var/www/gforge-projects/needle",
    "doc/manual-html" ).upload
end

desc "Publish the API documentation"
task :pubrdoc => [ :rdoc ] do
  Rake::SshDirPublisher.new(
    "minam@rubyforge.org",
    "/var/www/gforge-projects/needle/api",
    "api" ).upload
end

desc "Publish the FAQ document"
task :pubfaq => [ :faq ] do
  Rake::SshFilePublisher.new(
    "minam@rubyforge.org",
    "/var/www/gforge-projects/needle",
    "doc/faq",
    "faq.html" ).upload
end

desc "Publish the documentation"
task :pubdoc => [:pubrdoc, :pubman, :pubfaq ]
