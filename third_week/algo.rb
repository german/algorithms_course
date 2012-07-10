adj_list = {}

def random_contraction(graph)
  graph_keys = graph.collect{|k, v| k}
  puts 'graph_keys - ' + graph_keys.inspect

  start_vertex = graph_keys[rand(0..(graph_keys.size - 1))]
  puts 'start_vertex - ' + start_vertex.inspect

  random_adjacents = graph[start_vertex]
  puts 'random_adjacents - ' + random_adjacents.inspect

  puts 'random_adjacents.size - ' + random_adjacents.size.inspect
  a = rand(0..(random_adjacents.size - 1))
  puts 'a - ' + a.inspect

  fuse_with = random_adjacents[a]
  puts 'fuse_with - ' + fuse_with.inspect

  graph[start_vertex] += graph[fuse_with]

  # delete array at random_vertex key
  graph.delete fuse_with

  # change all mentions of fused vertex
  graph.map do |k,vertices|
    vertices.map! do |v|
      if v == fuse_with
        v = start_vertex
      end
      v
    end.compact
    {k => vertices}
  end

  graph[start_vertex].reject!{|v| v == start_vertex}

  puts 'graph - ' + graph.inspect
  puts 'graph.size - ' + graph.size.inspect
  puts
end

File.open('./kargerAdj.txt', 'r').each do |line|
  vertices = line.strip.split(/\s+/).map!{|v| v.to_i}
  adj_list[vertices.shift] = vertices
end

puts 'adj_list - ' + adj_list.inspect
puts 'adj_list.size - ' + adj_list.size.inspect

while adj_list.size > 2
  random_contraction(adj_list)
end

puts 'adj_list - ' + adj_list.inspect
puts 'adj_list.size - ' + adj_list.size.inspect
