# Takes an array of objects and sorts them with the highest level of concurrency
require 'test/unit'
class Merge
  include Test::Unit::Assertions

  def initialize(array)
    #pre
    assert array.is_a? Array
    assert array.size > 0

    @sortedArray = mergeSort(array)

    #post
    assert @sortedArray.size > 0
    assert array.size == @sortedArray.size
    assert @sortedArray.is_a? Array
  end

  def to_s
    @sortedArray.to_s
  end

  # mergeSort:
  # Inputs:
  # => array: An array of objects to be sorted
  # Outputs:
  # => A sorted version of array
  # Description:
  # => mergeSort takes an array of objects and sorts them using the merge sorting algorithm
  # => If an array is of size 1, it will return it as it doesn't need to be sorted any further
  # => Otherwise, it will do a series of 4 steps...
  # =>    1. Find the midpoint of the array. In the event an array has an even number of elements, the midpoint will be the smaller then the median. So for a = [2, 3, 4, 5], the midpoint is index 1 (so 3)
  # =>    2. Sort the left half of the array, from index 0 to the midpoint defined
  # =>    3. Sort the right half of the array, from index mid + 1 to the end
  # =>    4. Once these two are sorted, they will be combined (merge) together and returned

  def mergeSort(array)
    #pre
    assert array.is_a? Array
    assert array.size > 0

    # If the size of the array is not equal to 1... then it needs to be divided further
    if array.size != 1

      threads = []
      mid = (array.size - 1) / 2 # 1
      leftArray = []
      rightArray = []
      threads << Thread.new(array[0..mid]) { |arr| leftArray += mergeSort(arr) } # 2
      threads << Thread.new(array[mid+1..(array.size - 1)]) { |arr| rightArray += mergeSort(arr) } # 3
      threads.each { |thr| thr.join }

      #post
      assert threads.is_a? Array
      assert threads.each {|a| assert a.is_a? Thread}
      assert threads.each {|a| assert a.alive? == false }
      assert leftArray.is_a? Array
      assert rightArray.is_a? Array
      assert rightArray.size > 0
      assert leftArray.size > 0
      return merge(leftArray, rightArray) # 4
    else
      return array
    end
  end

  # merge:
  # Inputs:
  # => leftArray: A sorted array that was originally on the left for the array in mergeSort
  # => rightArray: A sorted array that was originally on the right for the array in mergeSort
  # Outputs:
  # => A merged array which is a sorted combination of the two inputs
  # Description:
  # => merge takes two sorted arrays and combines them into one sorted array
  # => A. If either input is nil, merge replaces it with [] (this is something that happens in binary search)
  # => B. For this algorithm to work correctly, the left array must be bigger then or equal to the right array. If this is not the case, then they are switched and merge is recalled
  # => C. If the right array is of size 0, no merging needs to happen... in this case the left array will be returned
  # => D. If each have only one element, they can be compared and swapped if neccesarry.
  # => If B-D are not executed, then the following will occur...
  # =>    1. The middle and end point of the left array are determined. The end of the right array is also determined
  # =>    2. The binary index of the right array is determined through binarySearch(). The binary index is the index of rightArray that is less then the midpoint of leftArray, and has the condition where rightArray[index + 1] is greater then the midpoint of leftArray.
  # =>       For example, if leftArray = [1, 3, 5, 7, 9], and rightArray = [2, 4, 9], then the binary index of rightArray is 1 (rightArray[1] = 4), since 4 < 5, but 9 (rightArray[2] = 9) > 5.
  # =>       In the event that a binary index cannot be found, it means all the values of rightArray are less then or greater then the midpoint.
  # =>       If they are less then, the binary index is rightArray.size. If they are greater then, the binary index is -1
  # =>    3. A left and right merged array are created. The left merged array calls merge on the the first half of left array, and the values of right array up to the binary index.
  # =>       The right merged array calls merge on the second half of left array, and the values of right array after the binary index.
  # =>    4. Once these two are sorted, they will be combined (merge) together and returned

  def merge(leftArray, rightArray)
    # A
    if leftArray == nil
      leftArray = []
    end
    # A
    if rightArray == nil
      rightArray = []
    end
    #pre
    assert leftArray.is_a? Array
    assert rightArray.is_a? Array
    assert leftArray.size >= 0
    assert rightArray.size >= 0

    # B
    if leftArray.size < rightArray.size
      return merge(rightArray, leftArray)
    end
    # C
    if rightArray.size == 0
      return leftArray
    end
    # If left array and right array are both only one element each (D)
    if leftArray.size == 1 and rightArray.size == 1
      leftValue = leftArray[0]
      rightValue = rightArray[0]
      # If index 0 is greater then index 1, this means they need to swap. If not, everything is okay and no work needs to be done
      if (leftValue <=> rightValue) == 1
        return [rightValue, leftValue]
      else
        return [leftValue, rightValue]
      end
    # The left and right halves are not 1 index each. This means that further merging must take place
    else
      leftMid = (leftArray.size - 1) / 2 # the middle of the left array (1)
      leftEnd = leftArray.length - 1 # the end of the left array (1)

      binaryIndex = binarySearch(leftArray[leftMid], rightArray) # binary search to determine the binary index (2)
      rightEnd = rightArray.length - 1 # the end of the right array (1)

      threads = []
      leftMergedArray = []
      rightMergedArray = []
      threads << Thread.new(leftArray[0, leftMid + 1], rightArray[0, binaryIndex + 1]) { |leftArr, rightArr| leftMergedArray += merge(leftArr, rightArr) } # 2
      threads << Thread.new(leftArray[leftMid + 1, leftEnd + 1], rightArray[binaryIndex + 1, rightEnd + 1]) { |leftArr, rightArr| rightMergedArray += merge(leftArr, rightArr) } # 3
      threads.each { |thr| thr.join }

      #post
      assert leftMergedArray.is_a? Array
      assert rightMergedArray.is_a? Array
      assert threads.is_a? Array
      assert threads.each {|a| assert a.is_a? Thread}
      assert threads.each {|a| assert a.alive? == false }
      assert leftMergedArray.size >= 0
      assert rightMergedArray.size >= 0
      assert leftMid = (leftEnd/2)
      assert rightEnd = rightArray.size - 1
      #leftMergedArray = merge(leftArray[0, leftMid + 1], rightArray[0, binaryIndex + 1]) # call a new merge (3)
      #rightMergedArray = merge(leftArray[leftMid + 1, leftEnd + 1], rightArray[binaryIndex + 1, rightEnd + 1]) # call a new merge (3)
      return leftMergedArray + rightMergedArray #combine (4)
    end
  end

  # binarySearch:
  # Inputs:
  # => value: The midpoint of the left array (from the merge function) that the binary index will be based off of
  # => array: The array to find the binary index for
  # Outputs:
  # => The binary index of array. This is the index of array where array[index] < value, but array[index + 1] > value. In the event this can't be found, either -1 or array.size will be returned. If array[index] = value, then that index is returned
  # Description:
  # => binarySearch uses the binary search algorithm to find the binary index of array.
  # => It starts by finding a lower and upper bound to search, based on the size of the array
  # => From here, it goes through a while loop until the proper index is found
  # => 1. index is defined by the midpoint of the subarray to be search. Starting out this will be the midpoint of the array
  # => 2. From here, if the value is found, that index will be returned
  # => 3. If the val at index is greater then value, the program checks if the index is 0. If it is, then the entire array is greater then value, and -1 is returned. If not, index - 1 will be returned if the previous value is smaller then value
  # =>    If these conditions are not met, the upper bound is decreased, creating a smaller subarray to search that cuts off the end of the previous array
  # => 4. If the val at index is less then value, the program checks if the index is size - 1. If it is, then the entire array is less then value, and size is returned. If not, index will be returned if the next array val is greater then value
  # =>    If these conditions are not met, the lower bound is increased, creating a smaller subarray to search that cuts off the beginning of the previous array

  def binarySearch(value, array)
    #pre
    assert array.is_a? Array
    assert value.is_a? Numeric
    assert array.size > 0

    size = array.size
    lowerBound = 0
    upperBound =  size - 1

    while true
      index = lowerBound + ((upperBound - lowerBound) / 2) # 1
      comparator = (array[index] <=> value)
      #post
      assert upperBound.is_a? Numeric
      assert lowerBound.is_a? Numeric
      assert lowerBound >= 0
      assert upperBound >= 0
      assert lowerBound <= upperBound
      assert index.is_a? Numeric
      assert index >= 0
      assert comparator.is_a? Numeric
      assert comparator.between? -1,1 #comparator is either -1, 0 ,1
      # If the value is found, return index (2)
      if comparator == 0
        return index
      # If the val at index is greater then the search value (3)
    elsif comparator == 1
        # This means the entire array is greater then value
        if index == 0
          return -1
        # If the previous index is less then value, return that index
      elsif (array[index - 1] <=> value) == -1
          return index - 1
        end
        upperBound = index - 1 # make new subarray
      # If the val at index is less then the search value (4)
      else
        # This means the entire array is less then value
        if index == size - 1
          return size
        # If the next index is greater then value, return this index
      elsif (array[index + 1] <=> value) == 1
          return index
        end
        lowerBound = index + 1 # make new subarray
      end
    end
  end
end

a = Merge.new([8, 3, 9, 2, 4])
puts a

test = Array.new(256) { Random.rand(-1000000...1000000) }

time_start = Time.now
b = Merge.new(test)
time_end = Time.now

puts "Total time = " + (time_end - time_start).to_s
puts b