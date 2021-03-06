defmodule Day20 do
  defmodule Control do
    defstruct enhancement_algorithm: nil,
              image: %{},
              generation: 0,
              min_x: 0,
              max_x: 0,
              min_y: 0,
              max_y: 0

    defimpl Collectable, for: Day20.Control do
      def into(control) do
        collector_fun = fn
          control_acc, {:cont, {{x, y}, v}} ->
            %{
              control_acc
              | image: Map.put(control_acc.image, {x, y}, v),
                min_x: min(x, control_acc.min_x),
                max_x: max(x, control_acc.max_x),
                min_y: min(y, control_acc.min_y),
                max_y: max(y, control_acc.max_y)
            }

          map_set_acc, :done ->
            map_set_acc

          _map_set_acc, :halt ->
            :ok
        end

        initial_acc = control

        {initial_acc, collector_fun}
      end
    end
  end

  import Advent2021

  @doc ~S"""
  --- Day 20: Trench Map ---
  With the scanners fully deployed, you turn their attention to mapping the
  floor of the ocean trench.

  When you get back the image from the scanners, it seems to just be random
  noise. Perhaps you can combine an image enhancement algorithm and the input
  image (your puzzle input) to clean it up a little.

  For example:
  #{test_input()}

  The first section is the image enhancement algorithm. It is normally given on
  a single line, but it has been wrapped to multiple lines in this example for
  legibility. The second section is the input image, a two-dimensional grid of
  light pixels (#) and dark pixels (.).

  The image enhancement algorithm describes how to enhance an image by
  simultaneously converting all pixels in the input image into an output image.
  Each pixel of the output image is determined by looking at a 3x3 square of
  pixels centered on the corresponding input image pixel. So, to determine the
  value of the pixel at (5,10) in the output image, nine pixels from the input
  image need to be considered: (4,9), (4,10), (4,11), (5,9), (5,10), (5,11),
  (6,9), (6,10), and (6,11). These nine input pixels are combined into a single
  binary number that is used as an index in the image enhancement algorithm
  string.

  For example, to determine the output pixel that corresponds to the very
  middle pixel of the input image, the nine pixels marked by [...] would need
  to be considered:

  # . . # .
  #[. . .].
  #[# . .]#
  .[. # .].
  . . # # #

  Starting from the top-left and reading across each row, these pixels are ...,
  then #.., then .#.; combining these forms ...#...#.. By turning dark pixels
  (.) into 0 and light pixels (#) into 1, the binary number 000100010 can be
  formed, which is 34 in decimal.

  The image enhancement algorithm string is exactly 512 characters long, enough
  to match every possible 9-bit binary number. The first few characters of the
  string (numbered starting from zero) are as follows:

  0         10        20        30  34    40        50        60        70
  |         |         |         |   |     |         |         |         |
  ..#.#..#####.#.#.#.###.##.....###.##.#..###.####..#####..#....#..#..##..##

  In the middle of this first group of characters, the character at index 34
  can be found: #. So, the output pixel in the center of the output image
  should be #, a light pixel.

  This process can then be repeated to calculate every pixel of the output
  image.

  Through advances in imaging technology, the images being operated on here are
  infinite in size. Every pixel of the infinite output image needs to be
  calculated exactly based on the relevant pixels of the input image. The small
  input image you have is only a small region of the actual infinite input
  image; the rest of the input image consists of dark pixels (.). For the
  purposes of the example, to save on space, only a portion of the
  infinite-sized input and output images will be shown.

  The starting input image, therefore, looks something like this, with more
  dark pixels (.) extending forever in every direction not shown here:

  ...............
  ...............
  ...............
  ...............
  ...............
  .....#..#......
  .....#.........
  .....##..#.....
  .......#.......
  .......###.....
  ...............
  ...............
  ...............
  ...............
  ...............

  By applying the image enhancement algorithm to every pixel simultaneously,
  the following output image can be obtained:

  ...............
  ...............
  ...............
  ...............
  .....##.##.....
  ....#..#.#.....
  ....##.#..#....
  ....####..#....
  .....#..##.....
  ......##..#....
  .......#.#.....
  ...............
  ...............
  ...............
  ...............

  Through further advances in imaging technology, the above output image can
  also be used as an input image! This allows it to be enhanced a second time:

  ...............
  ...............
  ...............
  ..........#....
  ....#..#.#.....
  ...#.#...###...
  ...#...##.#....
  ...#.....#.#...
  ....#.#####....
  .....#.#####...
  ......##.##....
  .......###.....
  ...............
  ...............
  ...............

  Truly incredible - now the small details are really starting to come through.
  After enhancing the original input image twice, 35 pixels are lit.

  Start with the original input image and apply the image enhancement algorithm
  twice, being careful to account for the infinite size of the images. How many
  pixels are lit in the resulting image?

  ## Example
    iex> part_1(test_input())
    35
  """
  def_solution part_1(stream_input) do
    do_solve(stream_input, 2)
  end

  @doc ~S"""
  --- Part Two ---
  You still can't quite make out the details in the image. Maybe you just
  didn't enhance it enough.

  If you enhance the starting input image in the above example a total of 50
  times, 3351 pixels are lit in the final output image.

  Start again with the original input image and apply the image enhancement
  algorithm 50 times. How many pixels are lit in the resulting image?

  ## Example
    iex> part_2(test_input())
    3351
  """
  def_solution part_2(stream_input) do
    do_solve(stream_input, 50)
  end

  def do_solve(stream, generations) do
    stream
    |> parse()
    |> evolve(generations)
    |> then(fn %{image: image} ->
      image
      |> Enum.filter(fn {_, pixel} -> pixel == 1 end)
      |> Enum.count()
    end)
  end

  def evolve(%{generation: generations} = control, generations), do: control

  def evolve(control, generations) do
    for point <- get_point_to_evolve(control),
        into: struct(Control, enhancement_algorithm: control.enhancement_algorithm) do
      {point, get_next(point, control)}
    end
    |> Map.put(:generation, control.generation + 1)
    |> evolve(generations)
  end

  def get_point_to_evolve(control) do
    for x <- (control.min_x - 1)..(control.max_x + 1),
        y <- (control.min_y - 1)..(control.max_y + 1) do
      {x, y}
    end
  end

  def get_next(point, control) do
    point
    |> neighbors()
    |> Enum.map(&Map.get_lazy(control.image, &1, fn -> get_default(control) end))
    |> then(fn binary_int -> control.enhancement_algorithm[binary_int] end)
  end

  def get_default(%{enhancement_algorithm: %{[0, 0, 0, 0, 0, 0, 0, 0, 0] => 0}}), do: 0
  def get_default(%{generation: generation}), do: rem(generation, 2)

  def neighbors({x, y}) do
    for y_prime <- (y - 1)..(y + 1), x_prime <- (x - 1)..(x + 1) do
      {x_prime, y_prime}
    end
  end

  def parse(stream) do
    [enchancement | input] = stream |> Stream.map(&to_charlist/1) |> Enum.to_list()

    enhancement_algorithm =
      enchancement
      |> Enum.with_index()
      |> Map.new(fn {value, index} ->
        pixel = if(value == ?#, do: 1, else: 0)
        binary_index = Integer.digits(index, 2)

        {List.duplicate(0, 9 - length(binary_index)) ++ binary_index, pixel}
      end)

    for {line, y} <- Enum.with_index(input),
        {value, x} <- Enum.with_index(line),
        into: struct(Control, enhancement_algorithm: enhancement_algorithm) do
      pixel = if(value == ?#, do: 1, else: 0)
      {{x, y}, pixel}
    end
  end

  def test_input do
    """
    ..#.#..#####.#.#.#.###.##.....###.##.#..###.####..#####..#....#..#..##..###..######.###...####..#..#####..##..#.#####...##.#.#..#.##..#.#......#.###.######.###.####...#.##.##..#..#..#####.....#.#....###..#.##......#.....#..#..#..##..#...##.######.####.####.#.#...#.......#..#.#.#...####.##.#......#..#...##.#.##..#...##.#.##..###.#......#.#.......#.#.#.####.###.##...#.....####.#..#..#.##.#....##..#.####....##...##..#...#......#.#.......#.......##..####..#...#.#.#...##..#.#..###..#####........#..####......#..#

    #..#.
    #....
    ##..#
    ..#..
    ..###
    """
  end
end
