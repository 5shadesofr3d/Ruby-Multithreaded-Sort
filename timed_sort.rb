require 'test/unit'
require_relative 'merge'
require_relative 'io_controller'
class TimedMultiSort
  include Test::Unit::Assertions

  #max_t is time in seconds
  def initialize(max_t)
    assert max_t.is_a? Numeric
    assert max_t > 0

    @max_t = max_t

    assert @max_t.is_a? Numeric
    assert @max_t > 0
  end

  def start
    assert @max_t.is_a? Numeric
    assert @max_t > 0
    assert @to_sort.is_a? Array
    @to_sort.each {|a| a.respond_to? :<=>}

    time_start = Time.now
    time_end = time_start + @max_t


    mergeThread = Thread.new do
      thr = Thread.current
      thr[:merge] = Merge.new(@to_sort)
    end

    while Time.now <= time_end and mergeThread.alive?
      #kill time
    end

    if Time.now > time_end
      puts "Stopped after maximum time of: " + (@max_t).to_s + " seconds"
    else
      puts "Finished sort after: " + (Time.now-time_start).to_s + " seconds of the maximum " + (@max_t).to_s + " seconds"
    end

    sortedData = []
    #kill merge thread, get data
    if mergeThread.key?("merge")
      sortedData = mergeThread[:merge]
    else
      sortedData = @to_sort
    end
    mergeThread.kill

    #kill all subthreads threads
    this_thread = Thread.current
    Thread.list.each do |thr|
      if thr != this_thread && thr != mergeThread
        thr.kill.join
      end
    end
    mergeThread.join #sometimes this thread fails to die before the assertion
                     #this is here to prevent that race condition
    puts "All threads stopped."

    #this_thread.kill
    #post
    assert time_end >= time_start
    assert mergeThread.alive? == false
    assert Thread.list.size == 1 #all threads are dead but this one

    return sortedData
  end


  def load_json(name,header)
    assert header.is_a? String #json header for data to sort
    assert name.is_a? String
    assert name.end_with? ".json"
    assert FileTest.exist? name

    io = IOController.new(name)
    @to_sort = io.parse_json(header)

    @to_sort.each {|a| assert a.respond_to? :<=> } #Confirm comparable implemented
    assert @to_sort.is_a? Array
  end

  def load_csv(name)
    assert name.is_a? String
    assert name.end_with? ".csv"
    assert FileTest.exist? name

    io = IOController.new(name)
    @to_sort = io.parse_csv

    @to_sort.each {|a| assert a.respond_to? :<=> } #Confirm comparable implemented
    assert @to_sort.is_a? Array
  end

  def load_txt(name)
    assert name.is_a? String
    assert name.end_with? ".txt"
    assert FileTest.exist? name

    io = IOController.new(name)
    @to_sort = io.parse_txt

    @to_sort.each {|a| assert a.respond_to? :<=> } #Confirm comparable implemented
    assert @to_sort.is_a? Array
  end

  def load_array(data)
    assert data.is_a? Array
    data.each {|a| assert a.respond_to? :<=> } #Confirm comparable implemented


    @to_sort = data

    @to_sort.each {|a| assert a.respond_to? :<=> } #Confirm comparable implemented
    assert @to_sort.is_a? Array
  end
end
