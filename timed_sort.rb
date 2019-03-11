require 'test/unit'
require_relative 'merge'
class TimedMultiSort
  include Test::Unit::Assertions

  #max_t is time in seconds
  def initialize(max_t,file = "")
    assert max_t.is_a? Numeric
    assert max_t > 0
    assert file.is_a? String

    time_start = Time.now
    time_end = time_start + max_t

    @to_sort = Array.new(3000) {Random.rand(0...10000)}
    t = Thread.new {Merge.new(@to_sort)}
    while Time.now <= time_end
      #kill time
    end
    #kill threads here:
    t.kill
  end
end

TimedMultiSort.new(0.5)