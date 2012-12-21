edges = {}
vertices = {}

Edge = Struct.new :node1, :node2, :cost

File.open('clustering1.txt').each_with_index do |line, edge_index|
  next if edge_index == 0
  node1, node2, cost = line.split(/\s+/).map{|v| v.to_i}
  edge = Edge.new(node1, node2, cost)

  edges[edge_index] = edge

  vertices[node1] ||= []
  vertices[node1].push edge_index

  vertices[node2] ||= []
  vertices[node2].push edge_index
end


