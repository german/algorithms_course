mst = []
adjacent_edges = {}
vertices = {}

Edge = Struct.new :node1, :node2, :cost

File.open('./edges.txt').each_with_index do |line, edge_index|
  next if edge_index == 0
  node1, node2, cost = line.split(/\s+/).map{|l| l.strip.to_i}
  edge = Edge.new(node1, node2, cost)

  adjacent_edges[edge_index] = edge

  vertices[node1] ||= []
  vertices[node1].push edge_index

  vertices[node2] ||= []
  vertices[node2].push edge_index
end

x = vertices.keys[rand(vertices.count)]

while mst.count != (vertices.count - 1) do
  edges_from_this_vertex = vertices[x].inject([]) do |sum, edge_index|
    sum << adjacent_edges[edge_index]
  end
  min_edge = edges_from_this_vertex.min{|m,n| m.cost <=> n.cost}
  x = min_edge.node2
  mst << min_edge
end

puts mst.count
puts mst.inject(0){|sum, e| sum += e.length}.inspect
