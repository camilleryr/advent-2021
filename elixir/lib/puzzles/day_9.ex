defmodule Day9 do
  import Advent2021

  @doc ~S"""
  --- Day 9: Smoke Basin ---
  These caves seem to be lava tubes. Parts are even still volcanically active;
  small hydrothermal vents release smoke into the caves that slowly settles
  like rain.

  If you can model how the smoke flows through the caves, you might be able to
  avoid it and be that much safer. The submarine generates a heightmap of the
  floor of the nearby caves for you (your puzzle input).

  Smoke flows to the lowest point of the area it's in. For example, consider
  the following heightmap:

  #{test_input()}

  Each number corresponds to the height of a particular location, where 9 is
  the highest and 0 is the lowest a location can be.

  Your first goal is to find the low points - the locations that are lower than
  any of its adjacent locations. Most locations have four adjacent locations
  (up, down, left, and right); locations on the edge or corner of the map have
  three or two adjacent locations, respectively. (Diagonal locations do not
  count as adjacent.)

  In the above example, there are four low points, all highlighted: two are in
  the first row (a 1 and a 0), one is in the third row (a 5), and one is in the
  bottom row (also a 5). All other locations on the heightmap have some lower
  adjacent location, and so are not low points.

  The risk level of a low point is --1 plus its height--. In the above example, the
  risk levels of the low points are 2, 1, 6, and 6. The sum of the risk levels
  of all low points in the heightmap is therefore 15.

  Find all of the low points on your heightmap. What is the sum of the risk
  levels of all low points on your heightmap?

  ## Example
    iex> part_1(test_input())
    15
  """
  def_solution part_1(stream_input) do
    stream_input
    |> parse_map()
    |> then(fn map -> Map.filter(map, &lower_than_neighbors(&1, map)) end)
    |> calculate_total_risk()
  end

  defp calculate_total_risk(low_points) do
    low_points
    |> Map.values()
    |> Enum.sum()
    |> Kernel.+(map_size(low_points))
  end

  defp lower_than_neighbors({point, val}, map) do
    point
    |> get_neighbors()
    |> Enum.all?(fn neighbor ->
      val < map[neighbor]
    end)
  end

  @doc ~S"""
  --- Part Two ---
  Next, you need to find the largest basins so you know what areas are most
  important to avoid.

  A basin is all locations that eventually flow downward to a single low point.
  Therefore, every low point has a basin, although some basins are very small.
  Locations of height 9 do not count as being in any basin, and all other
  locations will always be part of exactly one basin.

  The size of a basin is the number of locations within the basin, including
  the low point. The example above has four basins.

  The top-left basin, size 3:

  2199943210
  3987894921
  9856789892
  8767896789
  9899965678

  The top-right basin, size 9:

  2199943210
  3987894921
  9856789892
  8767896789
  9899965678

  The middle basin, size 14:

  2199943210
  3987894921
  9856789892
  8767896789
  9899965678

  The bottom-right basin, size 9:

  2199943210
  3987894921
  9856789892
  8767896789
  9899965678

  Find the three largest basins and multiply their sizes together. In the above
  example, this is 9 * 14 * 9 = 1134.

  What do you get if you multiply together the sizes of the three largest basins?

  ## Example
    iex> part_2(test_input())
    1134
  """
  def_solution part_2(stream_input) do
    stream_input
    |> parse_map()
    |> Map.filter(fn {_k, val} -> val != 9 end)
    |> split()
    |> find_solution()
  end

  defp split(map, acc \\ [])
  defp split(map, basins) when map_size(map) == 0, do: basins

  defp split(map, basins) do
    map
    |> Map.keys()
    |> List.first()
    |> expand(map)
    |> then(fn points ->
      {basin, remainder} = Map.split(map, MapSet.to_list(points))

      split(remainder, [basin | basins])
    end)
  end

  defp expand(point, map), do: expand(point, map, MapSet.new([point]))

  defp expand(point, map, points) do
    neighbors =
      point
      |> get_neighbors()
      |> Enum.reject(fn p ->
        is_nil(map[p]) or MapSet.member?(points, p)
      end)

    if Enum.empty?(neighbors) do
      points
    else
      updated_points = MapSet.union(points, MapSet.new(neighbors))

      Enum.reduce(neighbors, updated_points, fn neighbor, acc_points ->
        expand(neighbor, map, acc_points)
      end)
    end
  end

  defp find_solution(basins) do
    basins
    |> Enum.map(&map_size/1)
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.product()
  end

  defp get_neighbors({x, y}) do
    [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
  end

  defp parse_map(stream) do
    stream
    |> Stream.with_index()
    |> Stream.flat_map(fn {line, y} ->
      line
      |> String.codepoints()
      |> Stream.with_index()
      |> Stream.map(fn {cell, x} ->
        {{x, y}, String.to_integer(cell)}
      end)
    end)
    |> Map.new()
  end

  def print(map) do
    {{_x, max_y}, _} = Enum.max_by(map, fn {{_x, y}, _} -> y end)
    {{max_x, _y}, _} = Enum.max_by(map, fn {{x, _y}, _} -> x end)

    IO.puts("---------------------------------------")

    for y <- 0..max_y, x <- 0..max_x do
      if z = map[{x, y}], do: z, else: "-"
    end
    |> Enum.chunk_every(max_y + 1)
    |> Enum.map(&Enum.join/1)
    |> Enum.map(&IO.puts/1)

    IO.puts("---------------------------------------")
  end

  def test_input do
    """
    2199943210
    3987894921
    9856789892
    8767896789
    9899965678
    """
  end
end
