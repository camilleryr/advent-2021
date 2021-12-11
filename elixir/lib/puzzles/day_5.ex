defmodule Day5 do
  import Advent2021

  @doc ~S"""
  --- Day 5: Hydrothermal Venture ---
  You come across a field of hydrothermal vents on the ocean floor! These vents
  constantly produce large, opaque clouds, so it would be best to avoid them if
  possible.

  They tend to form in lines; the submarine helpfully produces a list of nearby
  lines of vents (your puzzle input) for you to review. For example:

  #{test_input()}

  Each line of vents is given as a line segment in the format x1,y1 -> x2,y2
  where x1,y1 are the coordinates of one end the line segment and x2,y2 are the
  coordinates of the other end. These line segments include the points at both
  ends. In other words:

  An entry like 1,1 -> 1,3 covers points 1,1, 1,2, and 1,3.
  An entry like 9,7 -> 7,7 covers points 9,7, 8,7, and 7,7.
  For now, only consider horizontal and vertical lines: lines where either x1 = x2 or y1 = y2.

  So, the horizontal and vertical lines from the above list would produce the following diagram:

  .......1..
  ..1....1..
  ..1....1..
  .......1..
  .112111211
  ..........
  ..........
  ..........
  ..........
  222111....

  In this diagram, the top left corner is 0,0 and the bottom right corner is
  9,9. Each position is shown as the number of lines which cover that point or
  . if no line covers that point. The top-left pair of 1s, for example, comes
  from 2,2 -> 2,1; the very bottom row is formed by the overlapping lines 0,9
  -> 5,9 and 0,9 -> 2,9.

  To avoid the most dangerous areas, you need to determine the number of points
  where at least two lines overlap. In the above example, this is anywhere in
  the diagram with a 2 or larger - a total of 5 points.

  Consider only horizontal and vertical lines. At how many points do at least
  two lines overlap?

  ## Example

    iex> part_1(test_input())
    5
  """
  def_solution part_1(stream_input) do
    do_solve(stream_input, &filter_lines/1)
  end

  defp filter_lines({{x, _y1}, {x, _y2}}), do: true
  defp filter_lines({{_x1, y}, {_x2, y}}), do: true
  defp filter_lines(_), do: false

  @doc ~S"""
  --- Part Two ---
  Unfortunately, considering only horizontal and vertical lines doesn't give
  you the full picture; you need to also consider diagonal lines.

  Because of the limits of the hydrothermal vent mapping system, the lines in
  your list will only ever be horizontal, vertical, or a diagonal line at
  exactly 45 degrees. In other words:

  An entry like 1,1 -> 3,3 covers points 1,1, 2,2, and 3,3.
  An entry like 9,7 -> 7,9 covers points 9,7, 8,8, and 7,9.
  Considering all lines from the above example would now produce the following diagram:

  1.1....11.
  .111...2..
  ..2.1.111.
  ...1.2.2..
  .112313211
  ...1.2....
  ..1...1...
  .1.....1..
  1.......1.
  222111....

  You still need to determine the number of points where at least two lines
  overlap. In the above example, this is still anywhere in the diagram with a 2
  or larger - now a total of 12 points.

  Consider all of the lines. At how many points do at least two lines overlap?

  ## Example

    iex> part_2(test_input())
    12
  """

  def_solution part_2(stream_input) do
    do_solve(stream_input)
  end

  defp do_solve(stream_input, filter \\ fn _ -> true end) do
    stream_input
    |> Enum.map(&line_to_points/1)
    |> Enum.filter(&filter.(&1))
    |> Enum.reduce({MapSet.new(), MapSet.new()}, &find_dupes/2)
    |> elem(1)
    |> MapSet.size()
  end

  def find_dupes(segment, acc) do
    segment
    |> build_line_segment()
    |> Enum.reduce(acc, fn point, {all_points, duped_points} ->
      if MapSet.member?(all_points, point) do
        {all_points, MapSet.put(duped_points, point)}
      else
        {MapSet.put(all_points, point), duped_points}
      end
    end)
  end

  @doc ~S"""
  ## Example

    iex> build_line_segment({{0, 9}, {5, 9}})
    [{5, 9}, {4, 9}, {3, 9}, {2, 9}, {1, 9}, {0, 9}]

    iex> build_line_segment({{0, 0}, {2, 2}})
    [{2, 2}, {1, 1}, {0, 0}]
  """
  def build_line_segment({{x, y1}, {x, y2}}) do
    end_point = {x, max(y1, y2)}
    start_point = {x, min(y1, y2)}
    build_line_segment_to(end_point, [start_point], fn {a, b} -> {a, b + 1} end)
  end

  def build_line_segment({{x1, y}, {x2, y}}) do
    end_point = {max(x1, x2), y}
    start_point = {min(x1, x2), y}

    build_line_segment_to(end_point, [start_point], fn {a, b} -> {a + 1, b} end)
  end

  def build_line_segment({p1, p2}) do
    [{_, y1} = start_point, {_, y2} = end_point] = Enum.sort([p1, p2])
    op = if y1 > y2, do: &Kernel.-(&1, 1), else: &Kernel.+(&1, 1)

    build_line_segment_to(end_point, [start_point], fn {a, b} -> {a + 1, op.(b)} end)
  end

  def build_line_segment_to(end_point, [end_point | _rest] = points, _inc), do: points

  def build_line_segment_to(end_point, [point | _rest] = points, incrementer) do
    build_line_segment_to(end_point, [incrementer.(point) | points], incrementer)
  end

  @doc ~S"""
  ## Example

    iex> line_to_points("0,9 -> 5,9")
    {{0, 9}, {5, 9}}
  """
  def line_to_points(line) do
    pattern = :binary.compile_pattern([",", " -> "])

    line
    |> String.split(pattern)
    |> Enum.map(&String.to_integer/1)
    |> then(fn [x1, y1, x2, y2] -> {{x1, y1}, {x2, y2}} end)
  end

  def test_input do
    """
    0,9 -> 5,9
    8,0 -> 0,8
    9,4 -> 3,4
    2,2 -> 2,1
    7,0 -> 7,4
    6,4 -> 2,0
    0,9 -> 2,9
    3,4 -> 1,4
    0,0 -> 8,8
    5,5 -> 8,2
    """
  end
end
