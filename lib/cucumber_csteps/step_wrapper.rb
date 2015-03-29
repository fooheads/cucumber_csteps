require 'ffi'

module CucumberCsteps

  module StdLib
    extend FFI::Library
    ffi_lib 'c'

    callback :signal_handler, [:int], :void
    attach_function :signal, [ :int, :signal_handler], :void
  end

  def self.try_and_catch_abort(&block)
    step_failed = false
    
    on_sigabrt = Proc.new do |signum|
      step_failed = true
      throw :error
    end

    StdLib.signal(6, on_sigabrt)
    catch(:error) do
      yield
    end

    if step_failed
      fail()
    end
     
  end

end
