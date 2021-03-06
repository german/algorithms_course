jobs = []

Job = Struct.new(:weight, :length, :k)

File.open('./jobs.txt').each_with_index do |line, index|
  next if index == 0
  weight, length = line.split(/\s+/).map{|l| l.strip.to_i}
  jobs << Job.new(weight, length, weight - length)
end

sorted_jobs = jobs.sort do |n, m|
  if n.k == m.k
    # higher weight
    m.weight <=> n.weight
  else
    m.k <=> n.k
  end
end

completion_time = 0
sum = 0
sorted_jobs.each do |j|
  completion_time += j.length
  sum += j.weight * completion_time
end
puts sum
