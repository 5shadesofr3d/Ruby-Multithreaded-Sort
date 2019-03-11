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
  end

  def start
    time_start = Time.now
    time_end = time_start + @max_t


    t = Thread.new {Merge.new(@to_sort)}


    while Time.now <= time_end and t.alive?
      #kill time
    end

    if Time.now > time_end
      puts "Stopped after maximum time of: " + (@max_t).to_s + " seconds"
    else
      puts "Finished sort after: " + (Time.now-time_start).to_s + " seconds of the maximum " + (@max_t).to_s + " seconds"
    end

    #kill all subthreads threads
    this_thread = Thread.current
    Thread.list.each do |thr|
      if not thr == this_thread
        thr.kill
      end
    end

    #kill this thread
    this_thread.kill
    assert Thread.list.size == 0
  end


  def load_json(name,header)
    assert header.is_a? String #json header for data to sort
    assert name.is_a? String
    assert name.end_with? ".json"

    io = IOController.new(name)
    @to_sort = io.parse_json(header)

    assert @to_sort.is_a? Array
  end

  def load_csv(name)
    assert name.is_a? String
    assert name.end_with? ".csv"

    io = IOController.new(name)
    @to_sort = io.parse_csv

    assert @to_sort.is_a? Array
  end

  def load_array(data)
    assert data.is_a? Array

    @to_sort = data

    assert @to_sort.is_a? Array
  end
end

sorter = TimedMultiSort.new(5)
sorter.load_array(Array.new(4000) {Random.rand(0..10000)})
sorter.start
