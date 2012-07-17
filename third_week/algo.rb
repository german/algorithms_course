adjacency_list = {}

def randomized_contraction(graph)
  graph_size = graph.size
  random_index = rand(1..graph_size)
  puts 'random_index - ' + random_index.to_s
  adjacent_vertices = graph[random_index]
  puts adjacent_vertices.inspect
  fuse_with = adjacent_vertices[rand(0..(adjacent_vertices.size))]
  puts 'fuse_with - ' + fuse_with.to_s
  adjacency_list[random_index] += adjacency_list[fuse_with]
  # remove self loops
end

File.open('./kargerAdj.txt', 'rb').each do |line|
  #p line.strip
  vertices = line.strip.split(/\s+/).map!{|v| v.to_i}
  adjacency_list[vertices.shift] = vertices
  puts adjacency_list.inspect
  randomized_contraction(adjacency_list)
end