array = []

File.open("./IntegerArray.txt", 'r').each do |line|
  array << line.to_i
end

n = array.size

def count_inversions(arr)
  return 0 if arr.size == 0
  sort_and_count(arr[0..(n/2)])
  sort_and_count(arr[(n/2)..n])
  merge_and_count_split(arr)
end

def count_split_inversions(arr)
end

def merge_sort(arr)
  return arr if arr.size==1
  
  merge_sort(arr[0..(n/2)])
  merge_sort(arr[(n/2)..n])
end

puts 'array size is - ' + array.size.to_s
puts 'count_inversions in array - ' + count_inversions(array).size
