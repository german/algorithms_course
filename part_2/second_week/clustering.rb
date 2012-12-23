edges = {}
vertices = {}

Edge = Struct.new :node1, :node2, :cost
Vertex = Struct.new :node, :leader

File.open('clustering1.txt').each_with_index do |line, edge_index|
  next if edge_index == 0
  node1, node2, cost = line.split(/\s+/).map{|v| v.to_i}

  v1 = Vertex.new node1, node1 # create vertex with the same leader (for union-find operation)
  vertices[v1] ||= []
  vertices[v1].push edge_index

  v2 = Vertex.new node2, node2
  vertices[v2] ||= []
  vertices[v2].push edge_index
  
  edge = Edge.new(v1, v2, cost)
  edges[edge_index] = edge
end

class SCC
  def initialize()
    @vertices_count = 0
    @edges = []
    @vertices = Set.new []
    @leader = nil
  end
  
  # checking whether the edge has some connections with this particular SCC
  def is_fit?(edge)
    @vertices.any?{|v| v.node == edge.node1.node || v.node == edge.node2.node}
  end
  
  def push_edge(edge)
    if @leader.nil?
      @leader = edge.node1.leader
      edge.node2.leader = @leader
    else
      edge.node1.leader = @leader
      edge.node2.leader = @leader
    end
    
    @vertices_count += 2
    @vertices << edge.node1
    @vertices << edge.node2
    @edges << edge
  end
  
  def merge(other)
    if @vertices_count > other.vertices_count
      # change leaders of the other SCC
      other.vertices.each{ |v| v.node.leader = @leader }
      @vertices_count += other.vertices_count
    else
      # change leaders of this SCC
      @vertices.each{ |v| v.node.leader = other.leader }
      other.vertices_count += @vertices_count
    end
  end
end

class MST
  def initialize()
    @mst = []
    @sccs = []
  end
  
  def push_edge(edge)
    insert_to_scc = @sccs.detect{|scc| scc.is_fit?(edge)}
    
    if insert_to_scc
      insert_to_scc.push_edge(edge)
    else # if edge is disconnected from any existing SCC then create a new one
      scc = SCC.new
      scc.push_edge(edge)
      @sccs << scc
    end
    
    if @mst.empty? 
      edge.node1.leader = edge.node2.leader
    else
      edge.node2
    end
    
    @mst << edge
  end 
  
  def check_loops(edge)
    root1 = edge.node1.leader 
    root2 = edge.node2.leader
    
    while root1 != root2 do
      root1 = edge.node1.leader 
      root2 = edge.node2.leader
      break if root1 == root2
      
    end
    
    return false
  end
  
  def count
    @mst.count
  end
end

mst = MST.new

# sort edges by their cost in increasing order
edges.sort{|m,n| m[1].cost <=> n[1].cost}.each do |edge|
  mst.push_edge(edge) if ! mst.check_loops(edge)
end

puts mst.count