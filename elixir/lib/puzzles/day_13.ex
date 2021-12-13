defmodule Day13 do
  defmodule Control do
    defstruct map: %{}, folds: []
  end

  import Advent2021

  @doc ~S"""
  --- Day 13: Transparent Origami ---
  You reach another volcanically active part of the cave. It would be nice if
  you could do some kind of thermal imaging so you could tell ahead of time
  which caves are too hot to safely enter.

  Fortunately, the submarine seems to be equipped with a thermal camera! When
  you activate it, you are greeted with:

  Congratulations on your purchase! To activate this infrared thermal imaging

  camera system, please enter the code found on page 1 of the manual.

  Apparently, the Elves have never used this feature. To your surprise, you
  manage to find the manual; as you go to open it, page 1 falls out. It's a
  large sheet of transparent paper! The transparent paper is marked with random
  dots and includes instructions on how to fold it up (your puzzle input). For
  example:

  #{test_input()}

  The first section is a list of dots on the transparent paper. 0,0 represents
  the top-left coordinate.  The first value, x, increases to the right.  The
  second value, y, increases downward.  So, the coordinate 3,0 is to the right
  of 0,0, and the coordinate 0,7 is below 0,0. The coordinates in this example
  form the following pattern, where # is a dot on the paper and . is an empty,
  unmarked position:

  ...#..#..#.
  ....#......
  ...........
  #..........
  ...#....#.#
  ...........
  ...........
  ...........
  ...........
  ...........
  .#....#.##.
  ....#......
  ......#...#
  #..........
  #.#........

  Then, there is a list of fold instructions. Each instruction indicates a line
  on the transparent paper and wants you to fold the paper up (for horizontal
  y=... lines) or left (for vertical x=... lines). In this example, the first
  fold instruction is fold along y=7, which designates the line formed by all
  of the positions where y is 7 (marked here with -):

  ...#..#..#.
  ....#......
  ...........
  #..........
  ...#....#.#
  ...........
  ...........
  -----------
  ...........
  ...........
  .#....#.##.
  ....#......
  ......#...#
  #..........
  #.#........

  Because this is a horizontal line, fold the bottom half up. Some of the dots
  might end up overlapping after the fold is complete, but dots will never
  appear exactly on a fold line. The result of doing this fold looks like this:

  #.##..#..#.
  #...#......
  ......#...#
  #...#......
  .#.#..#.###
  ...........
  ...........

  Now, only 17 dots are visible.

  Notice, for example, the two dots in the bottom left corner before the
  transparent paper is folded; after the fold is complete, those dots appear in
  the top left corner (at 0,0 and 0,1). Because the paper is transparent, the
  dot just below them in the result (at 0,3) remains visible, as it can be seen
  through the transparent paper.

  Also notice that some dots can end up overlapping; in this case, the dots
  merge together and become a single dot.

  The second fold instruction is fold along x=5, which indicates this line:

  #.##.|#..#.
  #...#|.....
  .....|#...#
  #...#|.....
  .#.#.|#.###
  .....|.....
  .....|.....

  Because this is a vertical line, fold left:

  #####
  #...#
  #...#
  #...#
  #####
  .....
  .....

  The instructions made a square!

  The transparent paper is pretty big, so for now, focus on just completing the
  first fold. After the first fold in the example above, 17 dots are visible -
  dots that end up overlapping after the fold is completed count as a single
  dot.

  How many dots are visible after completing just the first fold instruction on
  your transparent paper?


  ## Example
    iex> part_1(test_input())
    17
  """
  def_solution part_1(stream_input) do
    stream_input
    |> parse()
    |> Map.update!(:folds, &Enum.take(&1, 1))
    |> fold()
    |> then(fn %{map: map} -> map_size(map) end)
  end

  @doc ~S"""
  --- Part Two ---
  Finish folding the transparent paper according to the instructions. The
  manual says the code is always eight capital letters.

  What code do you use to activate the infrared thermal imaging camera system?

  ## Example
    iex> part_2(test_input())
  """

  def_solution part_2(stream_input) do
    stream_input
    |> parse()
    |> fold()
    |> then(fn %{map: map} ->
      map
      |> Map.new(fn {{x, y}, _value} -> {{-x, y}, "X"} end)
      |> Advent2021.print_grid()
    end)
  end

  def fold(%{folds: []} = control),
    do: %{control | map: Map.delete(control.map, :__x_fold_offset__)}

  def fold(%{map: map, folds: [fold | folds]}) do
    {direction, line} = update_fold(fold, map)

    updated_map =
      map
      |> Map.new(fn {point, facing} ->
        do_fold(direction, line, point, facing)
      end)
      |> set_x_fold_offset(direction, line)

    fold(%Control{map: updated_map, folds: folds})
  end

  def update_fold({:vertical, line}, map) do
    offset = Map.get(map, :__x_fold_offset__, 0)

    {:vertical, line + offset}
  end

  def update_fold(fold, _map), do: fold

  def set_x_fold_offset(map, :vertical, line), do: Map.put(map, :__x_fold_offset__, line + 1)
  def set_x_fold_offset(map, _, _), do: map

  def do_fold(:horizontal, line, {x, y}, facing) when y > line do
    new_y = y - (y - line) * 2
    {{x, new_y}, flip(facing)}
  end

  def do_fold(:vertical, line, {x, y}, facing) when x < line do
    new_x = x + (line - x) * 2
    {{new_x, y}, flip(facing)}
  end

  def do_fold(_, _, point, facing), do: {point, facing}

  def flip(:up), do: :down
  def flip(:down), do: :up

  defp parse(stream_input) do
    stream_input
    |> Enum.reduce(%Control{}, fn
      "fold along x=" <> line, acc ->
        %{acc | folds: [{:vertical, String.to_integer(line)} | acc.folds]}

      "fold along y=" <> line, acc ->
        %{acc | folds: [{:horizontal, String.to_integer(line)} | acc.folds]}

      point, acc ->
        [x, y] = String.split(point, ",")
        %{acc | map: Map.put(acc.map, {String.to_integer(x), String.to_integer(y)}, :up)}
    end)
    |> Map.update!(:folds, &Enum.reverse/1)
  end

  def test_input do
    """
    6,10
    0,14
    9,10
    0,3
    10,4
    4,11
    6,0
    6,12
    4,1
    0,13
    10,12
    3,4
    3,0
    8,4
    1,10
    2,14
    8,10
    9,0
    fold along y=7
    fold along x=5
    """
  end
end
