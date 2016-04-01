module Accel
  module GCThread
    @interval = 2
    @procs = []

    def self.setup(cond_proc, post_proc=nil, interval=nil)
      h = {:cond => cond_proc, :post => post_proc}
      @procs << h
      if interval and @interval > interval
        @interval = interval
      end
      h
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
        @procs.each{|h|
          begin
            if h[:cond].call
              GC.start
              @procs.each{|h|
                h[:post].call if h[:cond]
              }
              break
            end
          rescue => e
            Thread.main.raise(e.exception, e.message, e.backtrace)
          end
        }
      end
    end

  end
end
