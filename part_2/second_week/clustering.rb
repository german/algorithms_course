require 'set'

edges = {}
vertices = {}

Edge = Struct.new :node1, :node2, :cost, :scc
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
  
  edge = Edge.new(v1, v2, cost, nil) # link to scc would be nil for now
  edges[edge_index] = edge
end

puts 'imported all edges'

class SCC

  attr_accessor :leader

  def initialize(mst)
    @edges = []
    @mst = mst
    @vertices = Set.new []
  end
  
  def count
    @vertices.count
  end

  # checking whether the edge has some connections with this particular SCC
  def is_fit?(edge)
    @vertices.any?{|v| v.node == edge.node1.node || v.node == edge.node2.node}
  end
  
  # in fact it could be merge of two SCCs
  def push_edge(edge)
    if @leader.nil?
      @leader = edge.node1.leader
      edge.node2.leader = @leader
    else
      edge.node1.leader = @leader
      edge.node2.leader = @leader
    end
#puts 'edge.scc - ' + edge.scc.inspect
    if edge.scc
      puts "@vertices.count - #{@vertices.count}, edge.scc.count - #{edge.scc.count}"
      if @vertices.count > edge.scc.count
        # change leaders of the other SCC
        edge.scc.vertices.each{ |v| v.node.leader = @leader }

        @mst.delete_scc(edge.scc) # remove SCC from the list
      else
        # change leaders of this SCC
        @vertices.each{ |v| v.node.leader = edge.scc.leader }
      end
    else
      @vertices << edge.node1
      @vertices << edge.node2
      @edges << edge
    end

    edge.scc = self # save link to the SCC in the edge itself
  end  
end

class MST
  def initialize()
    @sccs = [] # consists of many SCCs
    @mst = []
  end
  
  def delete_scc(scc)
    @sccs.delete scc
    puts 'removed scc from list'
  end

  def push_edge(edge)
    insert_to_scc = @sccs.detect{|scc| scc.is_fit?(edge)}
    
    if insert_to_scc
      insert_to_scc.push_edge(edge)
    else # if edge is disconnected from any existing SCC then create a new one
      scc = SCC.new(self)
      scc.push_edge(edge)
      @sccs << scc
      puts 'created new SCC; now SCC.count is - ' + @sccs.count.to_s
    end
  
    @mst << edge
  end 
  
  def create_a_loop?(edge)
    @sccs.each do |scc|
      return true if edge.node1.leader == scc.leader || edge.node2.leader == scc.leader
    end

    return false
  end
  
  def count
    #@sccs.inject(0){|sum, scc| sum += scc.count}
    @mst.count    
  end
end

mst = MST.new

# sort edges by their cost in increasing order
edges.sort{|m,n| m[1].cost <=> n[1].cost}.each_with_index do |edge, i|
  puts "done with #{i} edges" if (i+1) % 10000 == 0
  mst.push_edge(edge[1]) if ! mst.create_a_loop? edge[1]
end

puts 'Edges in MST - ' + mst.count.inspect
