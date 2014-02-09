require "test/unit"

lib_dir = File.expand_path(File.join("..", "lib"), File.dirname(__FILE__))
$LOAD_PATH << lib_dir unless $LOAD_PATH.include?(lib_dir)

require "needle"

require "models/model_test"
