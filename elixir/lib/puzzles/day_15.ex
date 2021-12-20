defmodule Day15 do
  import Advent2021

  @doc ~S"""
  --- Day 15: Chiton ---
  You've almost reached the exit of the cave, but the walls are getting closer
  together. Your submarine can barely still fit, though; the main problem is
  that the walls of the cave are covered in chitons, and it would be best not
  to bump any of them.

  The cavern is large, but has a very low ceiling, restricting your motion to
  two dimensions. The shape of the cavern resembles a square; a quick scan of
  chiton density produces a map of risk level throughout the cave (your puzzle
  input). For example:

  #{test_input()}

  You start in the top left position, your destination is the bottom right
  position, and you cannot move diagonally. The number at each position is its
  risk level; to determine the total risk of an entire path, add up the risk
  levels of each position you enter (that is, don't count the risk level of
  your starting position unless you enter it; leaving it adds no risk to your
  total).

  Your goal is to find a path with the lowest total risk. In this example, a
  path with the lowest total risk is highlighted here:

  1163751742
  1381373672
  2136511328
  3694931569
  7463417111
  1319128137
  1359912421
  3125421639
  1293138521
  2311944581

  The total risk of this path is 40 (the starting position is never entered, so
  its risk is not counted).

  What is the lowest total risk of any path from the top left to the bottom
  right?

  ## Example
    iex> part_1(test_input())
    40
  """
  def_solution part_1(stream_input) do
    stream_input
    |> parse()
    |> dijkstra({0, 0})
    |> Enum.max_by(fn {{x, y}, _} -> x + y end)
    |> elem(1)
  end

  @doc ~S"""
  --- Part Two ---
  Now that you know how to find low-risk paths in the cave, you can try to find your way out.

  The entire cave is actually five times larger in both dimensions than you
  thought; the area you originally scanned is just one tile in a 5x5 tile area
  that forms the full map. Your original map tile repeats to the right and
  downward; each time the tile repeats to the right or downward, all of its
  risk levels are 1 higher than the tile immediately up or left of it. However,
  risk levels above 9 wrap back around to 1. So, if your original map had some
  position with a risk level of 8, then that same position on each of the 25
  total tiles would be as follows:

  8 9 1 2 3
  9 1 2 3 4
  1 2 3 4 5
  2 3 4 5 6
  3 4 5 6 7

  Each single digit above corresponds to the example position with a value of 8
  on the top-left tile. Because the full map is actually five times larger in
  both dimensions, that position appears a total of 25 times, once in each
  duplicated tile, with the values shown above.

  Here is the full five-times-as-large version of the first example above, with
  the original map in the top left corner highlighted:

  The total risk of this path is 315 (the starting position is still never
  entered, so its risk is not counted).

  Using the full map, what is the lowest total risk of any path from the top
  left to the bottom right?

  ## Example
    iex> part_2(test_input())
    315
  """

  def_solution part_2(stream_input) do
    stream_input
    |> parse()
    |> expand_board()
    |> dijkstra({0, 0})
    |> Enum.max_by(fn {{x, y}, _} -> x + y end)
    |> elem(1)
  end

  def expand_board(board) do
    {{max_x, max_y}, _} = Enum.max_by(board, fn {{x, y}, _} -> x + y end)

    for {{x, y}, v} <- board, xx <- 0..4, yy <- 0..4, into: %{} do
      new_val = if(v + (xx + yy) > 9, do: v + (xx + yy) - 9, else: v + (xx + yy))
      {{x + (max_x + 1) * xx, y + (max_y + 1) * yy}, new_val}
    end
  end

  def dijkstra(weight_map, starting_point) do
    distances = %{starting_point => 0}
    {destination, _} = Enum.max_by(weight_map, fn {{x, y}, _} -> x + y end)

    dijkstra(starting_point, :gb_trees.empty(), distances, weight_map, destination)
  end

  def dijkstra(destination, _queue, distances, _weights, destination), do: distances

  def dijkstra(vertex, queue, distances, weights, destination) do
    current_distance = distances[vertex]

    neighbors =
      vertex
      |> neightbors()
      |> Enum.filter(fn p -> Map.has_key?(weights, p) and not Map.has_key?(distances, p) end)

    updated_distances =
      Enum.reduce(neighbors, distances, fn neightbor, d ->
        neighbor_weight = weights[neightbor]
        current_neighbor_distance = current_distance + neighbor_weight

        Map.update(d, neightbor, current_neighbor_distance, fn existing_distance ->
          min(existing_distance, current_neighbor_distance)
        end)
      end)

    updated_queue = Enum.reduce(neighbors, queue, &put_queue(&2, updated_distances[&1], &1))

    {next_vertex, next_queue} = pop_queue(updated_queue)

    dijkstra(next_vertex, next_queue, updated_distances, weights, destination)
  end

  def put_queue(tree, priority, value) do
    key = {priority, value}

    case :gb_trees.lookup(key, tree) do
      :none -> :gb_trees.insert(key, value, tree)
      _ -> tree
    end
  end

  def pop_queue(tree) do
    {_, val, tree} = :gb_trees.take_smallest(tree)
    {val, tree}
  end

  def neightbors({x, y}) do
    [{x, y - 1}, {x + 1, y}, {x, y + 1}, {x - 1, y}]
  end

  def parse(stream) do
    stream
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      line
      |> to_charlist
      |> Enum.with_index()
      |> Enum.map(fn {char, x} ->
        {{x, y}, char - 48}
      end)
    end)
    |> Map.new()
  end

  def test_input() do
    """
    1163751742
    1381373672
    2136511328
    3694931569
    7463417111
    1319128137
    1359912421
    3125421639
    1293138521
    2311944581
    """
  end
end
