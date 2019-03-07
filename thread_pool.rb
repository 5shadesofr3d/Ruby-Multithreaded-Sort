require 'thread'
require 'test/unit'
require 'concurrent-ruby'

#Requires concurrent-ruby gem
class ThreadPool
  include Test::Unit::Assertions

  def initialize(numThreads)
    assert numThreads > 0
    @max_threads = numThreads
    @pool = Concurrent::FixedThreadPool.new(5)



  end

  #Assings a thread to the passed in task Proc object
  #Pool will allocate resources and complete the task
  def work(&task)
    assert task.is_a? Proc
    @pool.post do
      task.call
    end
  end

  #Begins shutdown and cleanup of threads
  #NOTE: the below shutdown will make all tasks complete first before shutdown.
  def shutdown
    @pool.shutdown
  end

  #returns TRUE if the thread pool is running and ready to go
  def running?
    return @pool.running?
  end

  #returns TRUE if done shutdown, false otherwise
  def shutdown?
    return @pool.shutdown?
  end

  #returns TRUE if we are currently shutting down
  def shuttingdown?
    return @pool.shuttingdown?
  end

  #Call this after shutdown to wait for shutdown to complete
  def wait_for_termination
    #pre
    assert shuttingdown?

    @pool.wait_for_termination

    #post
    assert shutdown?
  end
end

#Small test:
#myPool = ThreadPool.new(5)
#myPool.work { puts "Test1"}
#myPool.work { puts "Test2"}
#myPool.shutdown
#myPool.wait_for_termination
