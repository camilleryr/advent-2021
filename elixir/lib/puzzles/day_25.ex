defmodule Day25 do
  defmodule Control do
    defstruct board: %{}, east: [], south: []
  end

  import Advent2021

  @doc ~S"""
  --- Day 25: Sea Cucumber ---
  This is it: the bottom of the ocean trench, the last place the sleigh keys
  could be. Your submarine's experimental antenna still isn't boosted enough to
  detect the keys, but they must be here. All you need to do is reach the
  seafloor and find them.

  At least, you'd touch down on the seafloor if you could; unfortunately, it's
  completely covered by two large herds of sea cucumbers, and there isn't an
  open space large enough for your submarine.

  You suspect that the Elves must have done this before, because just then you
  discover the phone number of a deep-sea marine biologist on a handwritten
  note taped to the wall of the submarine's cockpit.

  "Sea cucumbers? Yeah, they're probably hunting for food. But don't worry,
  they're predictable critters: they move in perfectly straight lines, only
  moving forward when there's space to do so. They're actually quite polite!"

  You explain that you'd like to predict when you could land your submarine.

  "Oh that's easy, they'll eventually pile up and leave enough space for--
  wait, did you say submarine? And the only place with that many sea cucumbers
  would be at the very bottom of the Mariana--" You hang up the phone.

  There are two herds of sea cucumbers sharing the same region; one always
  moves east (>), while the other always moves south (v). Each location can
  contain at most one sea cucumber; the remaining locations are empty (.). The
  submarine helpfully generates a map of the situation (your puzzle input). For
  example:

  v...>>.vv>
  .vv>>.vv..
  >>.>v>...v
  >>v>>.>.v.
  v>v.vv.v..
  >.>>..v...
  .vv..>.>v.
  v.v..>>v.v
  ....v..v.>

  Every step, the sea cucumbers in the east-facing herd attempt to move forward
  one location, then the sea cucumbers in the south-facing herd attempt to move
  forward one location. When a herd moves forward, every sea cucumber in the
  herd first simultaneously considers whether there is a sea cucumber in the
  adjacent location it's facing (even another sea cucumber facing the same
  direction), and then every sea cucumber facing an empty location
  simultaneously moves into that location.

  So, in a situation like this:

  ...>>>>>...

  After one step, only the rightmost sea cucumber would have moved:

  ...>>>>.>..

  After the next step, two sea cucumbers move:

  ...>>>.>.>.

  During a single step, the east-facing herd moves first, then the south-facing
  herd moves. So, given this situation:

  ..........
  .>v....v..
  .......>..
  ..........

  After a single step, of the sea cucumbers on the left, only the south-facing
  sea cucumber has moved (as it wasn't out of the way in time for the
  east-facing cucumber on the left to move), but both sea cucumbers on the
  right have moved (as the east-facing sea cucumber moved out of the way of the
  south-facing sea cucumber):

  ..........
  .>........
  ..v....v>.
  ..........

  Due to strong water currents in the area, sea cucumbers that move off the
  right edge of the map appear on the left edge, and sea cucumbers that move
  off the bottom edge of the map appear on the top edge. Sea cucumbers always
  check whether their destination location is empty before moving, even if that
  destination is on the opposite side of the map:

  Initial state:

  ...>...
  .......
  ......>
  v.....>
  ......>
  .......
  ..vvv..

  After 1 step:

  ..vv>..
  .......
  >......
  v.....>
  >......
  .......
  ....v..

  After 2 steps:

  ....v>.
  ..vv...
  .>.....
  ......>
  v>.....
  .......
  .......

  After 3 steps:

  ......>
  ..v.v..
  ..>v...
  >......
  ..>....
  v......
  .......

  After 4 steps:

  >......
  ..v....
  ..>.v..
  .>.v...
  ...>...
  .......
  v......


  To find a safe place to land your submarine, the sea cucumbers need to stop
  moving. Again consider the first example:

  Initial state:

  #{test_input(0)}

  After 1 step:

  #{test_input(1)}

  After 2 steps:

  #{test_input(2)}

  After 3 steps:

  #{test_input(3)}

  After 4 steps:

  #{test_input(4)}

  After 5 steps:

  #{test_input(5)}
  ...

  After 10 steps:

  #{test_input(10)}
  ...

  After 20 steps:

  #{test_input(20)}
  ...

  After 30 steps:

  #{test_input(30)}
  ...

  After 40 steps:

  #{test_input(40)}
  ...

  After 50 steps:

  #{test_input(50)}
  ...

  After 55 steps:

  #{test_input(55)}

  After 56 steps:

  #{test_input(56)}

  After 57 steps:

  #{test_input(57)}

  After 58 steps:

  #{test_input(58)}

  In this example, the sea cucumbers stop moving after 58 steps.

  Find somewhere safe to land your submarine. What is the first step on which
  no sea cucumbers move?

  ## Example
    iex> part_1(test_input(0))
    58
  """
  def_solution part_1(stream_input) do
    stream_input
    |> parse()
    |> step()
  end

  def part_2(_), do: nil

  @doc ~S"""
  ## Example
    iex> for s <- 1..5, do: test_input(0) |> parse() |> step(s) |> Map.get(:board)
    for s <- 1..5, do: test_input(s) |> parse() |> Map.get(:board)
  """
  def step(control, final_step \\ nil, current_step \\ 0)

  def step(control, step, step), do: control

  def step(%{board: board} = control, final_step, current_step) do
    case control |> do_step(:east) |> do_step(:south) do
      %{board: ^board} -> current_step + 1
      updated -> step(updated, final_step, current_step + 1)
    end
  end

  def do_step(control, direction) do
    control
    |> Map.get(direction)
    |> Enum.reduce({%{}, []}, fn cucumber, {board_updates, cucumbers} ->
      {neighbor_cell, neighbor_point} = get_neighbor(cucumber, control.board, direction)

      if neighbor_cell == "." do
        updated_updates =
          Map.merge(board_updates, %{cucumber => ".", neighbor_point => get_cucumber(direction)})

        {updated_updates, [neighbor_point | cucumbers]}
      else
        {board_updates, [cucumber | cucumbers]}
      end
    end)
    |> then(fn {board_updates, updated_heard} ->
      control
      |> Map.update!(:board, &Map.merge(&1, board_updates))
      |> Map.put(direction, updated_heard)
    end)
  end

  def get_cucumber(:east), do: ">"
  def get_cucumber(:south), do: "v"

  @doc ~S"""
  ## Example
    iex> board =  test_input(1) |> parse() |> Map.get(:board)
    iex> get_neighbor({9, 8}, board, :south)
    {">", {9, 0}}
  """
  def get_neighbor({x, y}, grid, :east) do
    case Map.get(grid, {x + 1, y}) do
      nil -> {grid[{0, y}], {0, y}}
      cell -> {cell, {x + 1, y}}
    end
  end

  def get_neighbor({x, y}, grid, :south) do
    case Map.get(grid, {x, y + 1}) do
      nil -> {grid[{x, 0}], {x, 0}}
      cell -> {cell, {x, y + 1}}
    end
  end

  def parse(string) when is_binary(string) do
    string |> Advent2021.stream() |> parse()
  end

  def parse(stream) do
    for {line, y} <- Enum.with_index(stream),
        {cell, x} <- line |> String.split("", trim: true) |> Enum.with_index(),
        reduce: %Control{} do
      %{board: board, east: east, south: south} ->
        updated_board = Map.put(board, {x, y}, cell)
        updated_east = if(cell == ">", do: [{x, y} | east], else: east)
        updated_south = if(cell == "v", do: [{x, y} | south], else: south)

        %Control{board: updated_board, east: updated_east, south: updated_south}
    end
  end

  def test_input(0) do
    """
    v...>>.vv>
    .vv>>.vv..
    >>.>v>...v
    >>v>>.>.v.
    v>v.vv.v..
    >.>>..v...
    .vv..>.>v.
    v.v..>>v.v
    ....v..v.>
    """
  end

  def test_input(1) do
    """
    ....>.>v.>
    v.v>.>v.v.
    >v>>..>v..
    >>v>v>.>.v
    .>v.v...v.
    v>>.>vvv..
    ..v...>>..
    vv...>>vv.
    >.v.v..v.v
    """
  end

  def test_input(2) do
    """
    >.v.v>>..v
    v.v.>>vv..
    >v>.>.>.v.
    >>v>v.>v>.
    .>..v....v
    .>v>>.v.v.
    v....v>v>.
    .vv..>>v..
    v>.....vv.
    """
  end

  def test_input(3) do
    """
    v>v.v>.>v.
    v...>>.v.v
    >vv>.>v>..
    >>v>v.>.v>
    ..>....v..
    .>.>v>v..v
    ..v..v>vv>
    v.v..>>v..
    .v>....v..
    """
  end

  def test_input(4) do
    """
    v>..v.>>..
    v.v.>.>.v.
    >vv.>>.v>v
    >>.>..v>.>
    ..v>v...v.
    ..>>.>vv..
    >.v.vv>v.v
    .....>>vv.
    vvv>...v..
    """
  end

  def test_input(5) do
    """
    vv>...>v>.
    v.v.v>.>v.
    >.v.>.>.>v
    >v>.>..v>>
    ..v>v.v...
    ..>.>>vvv.
    .>...v>v..
    ..v.v>>v.v
    v.v.>...v.
    """
  end

  def test_input(10) do
    """
    ..>..>>vv.
    v.....>>.v
    ..v.v>>>v>
    v>.>v.>>>.
    ..v>v.vv.v
    .v.>>>.v..
    v.v..>v>..
    ..v...>v.>
    .vv..v>vv.
    """
  end

  def test_input(20) do
    """
    v>.....>>.
    >vv>.....v
    .>v>v.vv>>
    v>>>v.>v.>
    ....vv>v..
    .v.>>>vvv.
    ..v..>>vv.
    v.v...>>.v
    ..v.....v>
    """
  end

  def test_input(30) do
    """
    .vv.v..>>>
    v>...v...>
    >.v>.>vv.>
    >v>.>.>v.>
    .>..v.vv..
    ..v>..>>v.
    ....v>..>v
    v.v...>vv>
    v.v...>vvv
    """
  end

  def test_input(40) do
    """
    >>v>v..v..
    ..>>v..vv.
    ..>>>v.>.v
    ..>>>>vvv>
    v.....>...
    v.v...>v>>
    >vv.....v>
    .>v...v.>v
    vvv.v..v.>
    """
  end

  def test_input(50) do
    """
    ..>>v>vv.v
    ..v.>>vv..
    v.>>v>>v..
    ..>>>>>vv.
    vvv....>vv
    ..v....>>>
    v>.......>
    .vv>....v>
    .>v.vv.v..
    """
  end

  def test_input(55) do
    """
    ..>>v>vv..
    ..v.>>vv..
    ..>>v>>vv.
    ..>>>>>vv.
    v......>vv
    v>v....>>v
    vvv...>..>
    >vv.....>.
    .>v.vv.v..
    """
  end

  def test_input(56) do
    """
    ..>>v>vv..
    ..v.>>vv..
    ..>>v>>vv.
    ..>>>>>vv.
    v......>vv
    v>v....>>v
    vvv....>.>
    >vv......>
    .>v.vv.v..
    """
  end

  def test_input(57) do
    """
    ..>>v>vv..
    ..v.>>vv..
    ..>>v>>vv.
    ..>>>>>vv.
    v......>vv
    v>v....>>v
    vvv.....>>
    >vv......>
    .>v.vv.v..
    """
  end

  def test_input(58) do
    """
    ..>>v>vv..
    ..v.>>vv..
    ..>>v>>vv.
    ..>>>>>vv.
    v......>vv
    v>v....>>v
    vvv.....>>
    >vv......>
    .>v.vv.v..
    """
  end
end
