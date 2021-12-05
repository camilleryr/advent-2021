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
    |> Stream.map(&line_to_points/1)
    |> Stream.filter(&filter.(&1))
    |> Stream.flat_map(&build_line_segment/1)
    |> Enum.frequencies()
    |> Enum.filter(fn {_point, frequency} -> frequency > 1 end)
    |> Enum.count()
  end

  @doc ~S"""
  ## Example

    iex> build_line_segment({{0, 9}, {5, 9}})
    [{0, 9}, {1, 9}, {2, 9}, {3, 9}, {4, 9}, {5, 9}]

    iex> build_line_segment({{0, 0}, {2, 2}})
    [{0, 0}, {1, 1}, {2, 2}]
  """
  def build_line_segment({{x1, y1}, {x2, y2}}) do
    xs = x1..x2
    ys = y1..y2

    Stream.cycle(xs)
    |> Stream.zip(Stream.cycle(ys))
    |> Enum.take(max(Range.size(xs), Range.size(ys)))
  end

  @doc ~S"""
  ## Example

    iex> line_to_points("0,9 -> 5,9")
    {{0, 9}, {5, 9}}
  """
  def line_to_points(line) do
    line
    |> String.split([",", " -> "])
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
