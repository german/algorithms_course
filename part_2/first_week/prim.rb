require 'set'

mst = []
adjacent_edges = {}
vertices = {}

$verbose = false

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

seen_vertices = Set.new [ vertices.keys[rand(vertices.count)] ]

while mst.count != (vertices.count - 1) do
  puts 'seen_vertices - ' + seen_vertices.inspect if $verbose
  minimal_edge = seen_vertices.collect do |x|
    edges_from_this_vertex = vertices[x].inject([]) do |sum, edge_index|
      sum << adjacent_edges[edge_index]
    end

    min_edge = edges_from_this_vertex.min{|m,n| m.cost <=> n.cost}
    puts "min edge for vertex #{x} is #{min_edge.inspect}" if $verbose

    # check for loops
    while seen_vertices.include?(min_edge.node2) && seen_vertices.include?(min_edge.node1) do
      edges_from_this_vertex.delete min_edge
      if edges_from_this_vertex.empty?
        min_edge = nil
        break
      else
        min_edge = edges_from_this_vertex.min{|m,n| m.cost <=> n.cost}
      end
    end
    puts "[after loops deletion] min edge for vertex #{x} is #{min_edge.inspect}" if $verbose
    min_edge
  end.compact.min{|m,n| m.cost <=> n.cost}

  puts 'minimal_edge - ' + minimal_edge.inspect if $verbose
  puts if $verbose

  mst << minimal_edge
  seen_vertices << minimal_edge.node2
  seen_vertices << minimal_edge.node1
end

puts mst.count if $verbose
puts mst.inject(0){|sum, e| sum += e.cost}.inspect
