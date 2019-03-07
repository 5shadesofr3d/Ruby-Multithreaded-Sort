class Merge
  def initialize(array)
    @sortedArray = mergeSort(array, 0, array.size - 1)
  end

  def mergeSort(array, beg, end)
    if beg == end
      return array
    else
      mid = (beg + end / 2)
      leftArray = mergeSort(array, beg, mid)
      rightArray = mergeSort(array, mid + 1, end)
      return merge(leftArray, rightArray)
    end
  end
end
