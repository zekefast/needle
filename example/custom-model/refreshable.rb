require 'needle'
require 'needle/lifecycle/proxy'
require 'needle/pipeline/element'
require 'needle/thread'

class RefreshableProxy < Needle::Lifecycle::Proxy
  def initialize( *args )
    super
    @observables = nil
  end

  def add_refreshable_observer( observer )
    @observables ||= []
    @observables.push observer
  end

  def refresh!
    @instance = @instantiation_failed = nil
    self.respond_to?( :a ) # force the instance to reload
    if @observables
      @observables.each { |obs| obs.refresh! }
    end
  end
end

class Refreshable < Needle::Pipeline::Element

  set_default_priority 50

  def initialize_element
    @observables = options[:observe] || []
    @mutex = Needle::QueryableMutex.new
    @instance = nil
  end

  def call( *args )
    return @instance if @instance

    @mutex.synchronize do
      return @instance if @instance
      @instance = RefreshableProxy.new( succ, *args )
      @observables.each { |obs| obs.add_refreshable_observer( @instance ) }
    end

    return @instance
  end

end

def register_refreshable_model( reg )
  reg.pipeline_elements[:refreshable] = Refreshable
  reg.service_models[:refreshable] = [ :refreshable ]
end
