require 'set'

$edges = {}
$vertices = {}

Edge = Struct.new :node1, :node2, :cost, :scc do 
  def inspect
    "[#{self.node1.node} #{self.node2.node}]"
  end
end

Vertex = Struct.new :node, :leader

File.open('clustering1_test.txt').each_with_index do |line, edge_index|
  next if edge_index == 0
  node1, node2, cost = line.split(/\s+/).map{|v| v.to_i}

  v1 = Vertex.new node1, node1 # create vertex with the same leader (for union-find operation)
  $vertices[node1] ||= []
  $vertices[node1].push edge_index

  v2 = Vertex.new node2, node2
  $vertices[node2] ||= []
  $vertices[node2].push edge_index
  
  edge = Edge.new(v1, v2, cost, nil) # link to scc would be nil for now
  $edges[edge_index] = edge
end

puts 'imported all edges'
puts $vertices.inspect
puts $edges.inspect

class SCC

  attr_accessor :leader

  def initialize(mst)
    @edges = []
    @mst = mst
    @vertices = Set.new []
  end
  
  def edges
    @edges
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
    
    adj_edge1_index = $vertices[edge.node1.node].first # we could select here first edge since 
    adj_edge2_index = $vertices[edge.node2.node].first # they all are adjacent

    if adj_edge2_index && adj_edge1_index
      puts "adj_edge1_index - #{adj_edge1_index}, adj_edge2_index - #{adj_edge2_index}"
    end

    adj_edge1 = $edges[adj_edge1_index]
    adj_edge2 = $edges[adj_edge2_index]

    # 3 branches should be considered
    # 1st - edge is merged to only scc with adj edge1                         o--o--o  o----o 
    # 2nd - edge is merged to only scc with adj edge2                         o--o  o--o----o
    # 3rd - edge is merged to scc1 or scc2 and these sccs are merges as well  o--o---o--o

    if adj_edge1 && adj_edge2
      if adj_edge1.scc && adj_edge2.scc # merging 2 SCCs
        puts "merging sccs"
        if adj_edge1.scc.count > adj_edge2.scc.count
          @vertices.each{|v| v.node.leader = adj_edge1.scc.leader }
          # change leaders of SCC of adjacent edge 2
          adj_edge2.scc.vertices.each{|v| v.node.leader = adj_edge1.scc.leader }
          adj_edge2.scc.edges.each{|e| e.scc = adj_edge1.scc}
          @mst.delete_scc(adj_edge2.scc) # remove SCC from the list
        else
          @vertices.each{|v| v.node.leader = adj_edge2.scc.leader }
          # change leaders of SCC of adjacent edge 1
          adj_edge1.scc.vertices.each{|v| v.node.leader = adj_edge2.scc.leader }
          adj_edge1.scc.edges.each{|e| e.scc = adj_edge2.scc}
          @mst.delete_scc(adj_edge1.scc) # remove SCC from the list
        end
      elsif adj_edge1.scc || adj_edge2.scc
        scc = adj_edge1.scc || adj_edge2.scc # only one should be available
        @vertices.each{ |v| v.node.leader = scc.leader }
        puts 'adding edge ' + edge.inspect + ' to scc ' + scc.inspect
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
  
  def inspect
    @mst.map{|edge| "[#{edge.node1.node} #{edge.node2.node}]"}.join(', ').to_s
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
    puts 'checking whether an edge is creating a loop - ' + edge.inspect
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
$edges.sort{|m,n| m[1].cost <=> n[1].cost}.each_with_index do |edge, i|
  puts "done with #{i} edges" if (i+1) % 10000 == 0
  mst.push_edge(edge[1]) if ! mst.create_a_loop? edge[1]
end

puts 'Edges in MST - ' + mst.count.inspect
puts mst.inspect
