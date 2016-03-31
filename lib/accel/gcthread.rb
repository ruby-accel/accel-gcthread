module Accel
  module GCThread
    @interval = 2
    @cond_procs = []
    @post_procs = []

    def self.setup(cond_proc, post_proc, interval=nil)
      @cond_procs << cond_proc
      @post_procs << post_proc
      if interval and @interval > interval
        @interval = interval
      end
    end

    def self.thread
      @thread
    end

    def self.interval
      @interval
    end

    def self.set_interval!(interval)
      @interval = interval
    end

    @thread = Thread.start do
      loop do
        sleep(@interval)
        @cond_procs.each{|cproc|
          begin
            if cproc.call
              GC.start
              @post_procs.each{|pproc|
                pproc.call
              }
              break
            end
          rescue => e
            b = e.backtrace.join("\n")
            $stderr.puts "at Accel::GCThread"
            $stderr.puts e.inspect
            $stderr.puts b
            GC.start
          end
        }
      end
    end

  end
end
