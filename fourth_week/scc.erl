-module(scc).
-compile(export_all).

%%for(Max, Max, F) -> [F(Max)];
%%for(I, Max, F)   -> [F(I)|for(I+1, Max, F)].

process_all_lines(Handle) ->
	case file:read_line(Handle) of
		%%{error, Reason} ->
		%%	io:format("cannot open file~n"),
		%%	exit().
		{ok, LineString} ->
	    {ok, [FirstNode, SecondNode]} = regexp:split(LineString, "\s+"),
			%% io:format("FirstNode ~p, SecondNode ~p~n", [FirstNode, SecondNode]),
	    {StartStripped, _} = string:to_integer(string:strip(FirstNode)),

	    {EndStripped, _} = string:to_integer(string:strip(SecondNode)),

			ets:insert(graph, [{StartStripped, EndStripped}]),
			ets:insert(rev_graph, [{EndStripped, StartStripped}]),

	    %% we're working with end_node here since first DFS loop is related on reversed graph
			[{K, V}] = ets:lookup(last_vertex, last),
	    case (EndStripped > V) of
	      true -> ets:insert(last_vertex, [{last, EndStripped}]);
				false -> []
	    end,
	
			process_all_lines(Handle);
	  eof -> []
	end.
	
find_scc() ->
	ets:new(graph, [named_table, bag]),
	ets:new(rev_graph, [named_table, bag]),
  ets:new(last_vertex, [named_table, set]),
	ets:insert(last_vertex, [{last, 1}]),
	
	{ok, File} = file:open('SCC_test.txt', read),
	
	try process_all_lines(File)
	  after file:close(File)
	end,

	io:format("Size ~p~n", [ets:info(graph, size)]),
	io:format("7 - ~p~n", [ets:lookup(graph, 7)]),
	io:format("last vertex - ~p~n", [ets:lookup(last_vertex, last)]).