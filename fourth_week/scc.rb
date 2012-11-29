RubyVM::InstructionSequence.compile_option = {:tailcall_optimization => true, :trace_instruction => false}

@graph = {}
@rev_graph = {}

=begin
File.open('SCC.txt', 'r').each do |line|
  start_node, end_node = line.split(/\s+/)
  start_node.strip!
  end_node.strip!
  graph[start_node.to_i] ||= []
  graph[start_node.to_i] << end_node.to_i
  num_of_lines += 1
end
=end
#puts 'graph[1] - ' + graph[1].inspect
#puts 'graph[875714] - ' + graph[875714].inspect
#puts 'num_of_lines - ' + num_of_lines.inspect
#puts 'graph.size - ' + graph.size.inspect

last_vertex = 1

File.open('SCC.txt', 'r').each do |line|
  start_node, end_node = line.split(/\s+/)
  start_node.strip!
  end_node.strip!
  
  end_node = end_node.to_i
  start_node = start_node.to_i
  
  @graph[start_node] ||= []
  @graph[start_node] << end_node
  
  @rev_graph[end_node] ||= []
  @rev_graph[end_node] << start_node
  
  #if start_node == 17369
  #  puts '@rev_graph[start_node] - ' + @rev_graph[start_node].inspect
  #  puts '@graph[end_node] - ' + @graph[end_node].inspect
  #end
  
  # we're working with end_node here since first DFS loop is related on reversed graph
  if end_node > last_vertex
    last_vertex = end_node
  end
end

puts 'last_vertex - ' + last_vertex.inspect
#puts '@rev_graph - ' + @rev_graph.inspect

@t = 0
s = nil

@used_vertices = []
@finishing_times = {}
@finishing_graph = {}

def dfs_i(v)
  @used_vertices << v
  
  #return if leaf
  return if @rev_graph[v].nil?
  
  i = 0
  puts "@rev_graph[#{v}] - " + @rev_graph[v].inspect
  while i < @rev_graph[v].size
    puts "@rev_graph[#{v}][#{i}] - " + @rev_graph[v][i].inspect
    dfs_i(@rev_graph[v][i]) if ! @used_vertices.include?(@rev_graph[v][i])
    i += 1
  end
  @t += 1
  puts '@t - ' + @t.inspect
  @finishing_times[v] = @t
end

last_vertex.downto(1) do |i|
  next if @used_vertices.include?(i)
  s = i
  dfs_i(i)
end

#puts '@finishing_times - ' + @finishing_times.inspect

@finishing_times.each do |v, time|
  @finishing_graph[time] = @graph[v].map{|vert| @finishing_times[vert]}
end

#puts '@finishing_graph - ' + @finishing_graph.inspect

@used_vertices = []

eval <<end
  def dfs_ii(v)
    #puts 'v - ' + v.inspect
    
    @used_vertices << v
    
    @num_of_nodes[@leader] ||= 0
    @num_of_nodes[@leader] += 1
    
    @finishing_graph[v].each do |i|
      if ! @used_vertices.include?(i)
        dfs_ii(i)
      end
    end
  end
end

@scc = 0
@leader = nil
@num_of_nodes = {}

# second dfs loop (by finishing times)
last_vertex.downto(1) do |i|
  #puts 'i - ' + i.inspect
  next if @used_vertices.include?(i)
  @leader = i
  
  dfs_ii(i)
  
  @scc += 1
  #puts '@scc - ' + @scc.inspect
end

puts 'scc - ' + @scc.inspect
puts @num_of_nodes.inspect
