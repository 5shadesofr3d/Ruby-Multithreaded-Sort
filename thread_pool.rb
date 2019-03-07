require 'thread'
require 'test/unit'
require 'concurrent-ruby'

#Requires concurrent-ruby gem
class ThreadPool
  def initialize(numThreads)
    #assert numThreads > 0
    @max_threads = numThreads
    @pool = Concurrent::FixedThreadPool.new(5)



  end


  def work(&task)
    @pool.post do
      task.call()
    end
  end

  def shutdown
    #NOTE: the below shutdown will make all tasks complete first before shutdown.
    @pool.shutdown
  end

  def running?
    return @pool.running?
  end

  def shutdown?
    return @pool.shutdown?
  end

  def shuttingdown?
    return @pool.shutdown?
  end

  def wait_for_termination
    #Call this after shutdown to wait for shutdown to complete
    @pool.wait_for_termination
  end
end

#Small test:
#myPool = ThreadPool.new(5)
#myPool.work { puts "Test1"}
#myPool.work { puts "Test2"}
#myPool.shutdown
#myPool.wait_for_termination