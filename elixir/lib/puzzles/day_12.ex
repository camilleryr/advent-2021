defmodule Day12 do
  import Advent2021

  @doc ~S"""
  --- Day 12: Passage Pathing ---
  With your submarine's subterranean subsystems subsisting suboptimally, the
  only way you're getting out of this cave anytime soon is by finding a path
  yourself. Not just a path - the only way to know if you've found the best
  path is to find all of them.

  Fortunately, the sensors are still mostly working, and so you build a rough
  map of the remaining caves (your puzzle input). For example:

  #{test_input(1)}

  This is a list of how all of the caves are connected. You start in the cave
  named start, and your destination is the cave named end. An entry like b-d
  means that cave b is connected to cave d - that is, you can move between
  them.

  So, the above cave system looks roughly like this:

    start
    /   \
  c--A-----b--d
    \   /
     end

  Your goal is to find the number of distinct paths that start at start, end at
  end, and don't visit small caves more than once. There are two types of
  caves: big caves (written in uppercase, like A) and small caves (written in
  lowercase, like b). It would be a waste of time to visit any small cave more
  than once, but big caves are large enough that it might be worth visiting
  them multiple times. So, all paths you find should visit small caves at most
  once, and can visit big caves any number of times.

  Given these rules, there are 10 paths through this example cave system:
  start,A,b,A,c,A,end
  start,A,b,A,end
  start,A,b,end
  start,A,c,A,b,A,end
  start,A,c,A,b,end
  start,A,c,A,end
  start,A,end
  start,b,A,c,A,end
  start,b,A,end
  start,b,end

  (Each line in the above list corresponds to a single path; the caves visited
  by that path are listed in the order they are visited and separated by
  commas.)

  Note that in this cave system, cave d is never visited by any path: to do so,
  cave b would need to be visited twice (once on the way to cave d and a second
  time when returning from cave d), and since cave b is small, this is not
  allowed.

  Here is a slightly larger example:
  #{test_input(2)}

  The 19 paths through it are as follows:
  start,HN,dc,HN,end
  start,HN,dc,HN,kj,HN,end
  start,HN,dc,end
  start,HN,dc,kj,HN,end
  start,HN,end
  start,HN,kj,HN,dc,HN,end
  start,HN,kj,HN,dc,end
  start,HN,kj,HN,end
  start,HN,kj,dc,HN,end
  start,HN,kj,dc,end
  start,dc,HN,end
  start,dc,HN,kj,HN,end
  start,dc,end
  start,dc,kj,HN,end
  start,kj,HN,dc,HN,end
  start,kj,HN,dc,end
  start,kj,HN,end
  start,kj,dc,HN,end
  start,kj,dc,end

  Finally, this even larger example has 226 paths through it:
  #{test_input(3)}

  How many paths through this cave system are there that visit small caves at most once?

  ## Example
    iex> part_1(test_input(1))
    10

    iex> part_1(test_input(2))
    19

    iex> part_1(test_input(3))
    226
  """
  def_solution part_1(stream_input) do
    do_solve(stream_input, &any_small_caves_visited_twice/1)
  end

  def any_small_caves_visited_twice({_visited, []}), do: false
  def any_small_caves_visited_twice(_), do: true

  @doc ~S"""
  --- Part Two ---
  After reviewing the available paths, you realize you might have time to visit
  a single small cave twice. Specifically, big caves can be visited any number
  of times, a single small cave can be visited at most twice, and the remaining
  small caves can be visited at most once. However, the caves named start and
  end can only be visited exactly once each: once you leave the start cave, you
  may not return to it, and once you reach the end cave, the path must end
  icavemmediately.

  Now, the 36 possible paths through the first example above are:

  start,A,b,A,b,A,c,A,end
  start,A,b,A,b,A,end
  start,A,b,A,b,end
  start,A,b,A,c,A,b,A,end
  start,A,b,A,c,A,b,end
  start,A,b,A,c,A,c,A,end
  start,A,b,A,c,A,end
  start,A,b,A,end
  start,A,b,d,b,A,c,A,end
  start,A,b,d,b,A,end
  start,A,b,d,b,end
  start,A,b,end
  start,A,c,A,b,A,b,A,end
  start,A,c,A,b,A,b,end
  start,A,c,A,b,A,c,A,end
  start,A,c,A,b,A,end
  start,A,c,A,b,d,b,A,end
  start,A,c,A,b,d,b,end
  start,A,c,A,b,end
  start,A,c,A,c,A,b,A,end
  start,A,c,A,c,A,b,end
  start,A,c,A,c,A,end
  start,A,c,A,end
  start,A,end
  start,b,A,b,A,c,A,end
  start,b,A,b,A,end
  start,b,A,b,end
  start,b,A,c,A,b,A,end
  start,b,A,c,A,b,end
  start,b,A,c,A,c,A,end
  start,b,A,c,A,end
  start,b,A,end
  start,b,d,b,A,c,A,end
  start,b,d,b,A,end
  start,b,d,b,end
  start,b,end

  The slightly larger example above now has 103 paths through it, and the even
  lcavearger example now has 3509 paths through it.

  Given these new rules, how many paths through this cave system are there?
  #
  ## Example
    iex> part_2(test_input(1))
    36

    iex> part_2(test_input(2))
    103

    iex> part_2(test_input(3))
    3509
  """
  def_solution part_2(stream_input) do
    do_solve(stream_input, &at_most_one_small_cave_visited_twice/1)
  end

  def at_most_one_small_cave_visited_twice({_visited, []}), do: false
  def at_most_one_small_cave_visited_twice({_visited, [_]}), do: false
  def at_most_one_small_cave_visited_twice(_), do: true

  def do_solve(stream_input, rejector) do
    graph = :digraph.new()

    stream_input
    |> build_graph(graph)
    |> get_paths(rejector)
    |> length()
  end

  def get_paths(graph, paths \\ [{[:start], {MapSet.new(), []}}], rejector)

  def get_paths(graph, paths, rejector) do
    updated_paths = Enum.flat_map(paths, &expand(graph, &1, rejector))

    if Enum.all?(updated_paths, &completed?/1) do
      updated_paths
    else
      get_paths(graph, updated_paths, rejector)
    end
  end

  defp expand(graph, {[last_node | _rest] = nodes, smalls_visited} = path, rejector) do
    if completed?(path) do
      [path]
    else
      next_nodes = graph |> :digraph.out_neighbours(last_node)

      next_nodes
      |> Enum.map(fn next -> {[next | nodes], update_smalls_visited(smalls_visited, next)} end)
      |> Enum.reject(fn {_updated_path, visited_smalls} ->
        rejector.(visited_smalls)
      end)
    end
  end

  defp update_smalls_visited({visited, visited_again}, {key, :small}) do
    if MapSet.member?(visited, key) do
      {visited, [key | visited_again]}
    else
      {MapSet.put(visited, key), visited_again}
    end
  end

  defp update_smalls_visited(visited, _), do: visited

  defp completed?({[:end | _], _}), do: true
  defp completed?(_), do: false

  def build_graph(stream_input, graph) do
    stream_input
    |> Stream.map(fn line ->
      [start_node, end_node] = String.split(line, "-")

      [v1, v2] = Enum.sort([to_vertex(start_node), to_vertex(end_node)])

      :digraph.add_vertex(graph, v1)
      :digraph.add_vertex(graph, v2)

      :digraph.add_edge(graph, v1, v2)

      unless v1 == :start do
        :digraph.add_edge(graph, v2, v1)
      end
    end)
    |> Stream.run()

    graph
  end

  defp to_vertex("start"), do: :start
  defp to_vertex("end"), do: :end
  defp to_vertex(vertex), do: {String.to_atom(vertex), size(vertex)}

  def size(vertex), do: if(String.upcase(vertex) == vertex, do: :big, else: :small)

  def test_input(1) do
    """
    start-A
    start-b
    A-c
    A-b
    b-d
    A-end
    b-end
    """
  end

  def test_input(2) do
    """
    dc-end
    HN-start
    start-kj
    dc-start
    dc-HN
    LN-dc
    HN-end
    kj-sa
    kj-HN
    kj-dc
    """
  end

  def test_input(3) do
    """
    fs-end
    he-DX
    fs-he
    start-DX
    pj-DX
    end-zg
    zg-sl
    zg-pj
    pj-he
    RW-he
    fs-DX
    pj-RW
    zg-RW
    start-pj
    he-WI
    zg-he
    pj-fs
    start-RW
    """
  end
end
