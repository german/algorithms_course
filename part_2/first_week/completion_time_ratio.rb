jobs = []

Job = Struct.new(:weight, :length)

File.open('./jobs.txt').each_with_index do |line, index|
  next if index == 0
  weight, length = line.split(/\s+/)
  jobs << Job.new(weight.strip.to_i, length.strip.to_i)
end

sorted_jobs = jobs.sort do |n, m|
  k1 = n.weight / n.length.to_f
  k2 = m.weight / m.length.to_f
  k1 <=> k2
end

puts sorted_jobs.inject(0){|sum, j| sum += j.length}
