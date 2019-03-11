#Group Members
# Vishal Patel
# Rizwan Qureshi
# Curtis Goud
# Jose Ramirez
# Jori Romans

require_relative 'timed_sort.rb'

sorter = TimedMultiSort.new(10)
#ar = ["str","a","test","rnd","sort","me"]
ar2 = Array.new(400) {Random.rand(0..10000)}
sorter.load_array(ar2)
#sorter.load_csv("test.csv")
#sorter.load_json("test.json","data")
#sorter.load_txt("test.txt")
sorter.start
