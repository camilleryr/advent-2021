defmodule Day23 do
  defmodule Control do
    defstruct board: %{},
              pieces: %{},
              score: 0,
              history: MapSet.new(),
              last_move: nil,
              complete: false
  end

  import Advent2021

  @doc ~S"""
  --- Day 23: Amphipod ---
  A group of amphipods notice your fancy submarine and flag you down. "With
  such an impressive shell," one amphipod says, "surely you can help us with a
  question that has stumped our best scientists."

  They go on to explain that a group of timid, stubborn amphipods live in a
  nearby burrow. Four types of amphipods live there: Amber (A), Bronze (B),
  Copper (C), and Desert (D). They live in a burrow that consists of a hallway
  and four side rooms. The side rooms are initially full of amphipods, and the
  hallway is initially empty.

  They give you a diagram of the situation (your puzzle input), including
  locations of each amphipod (A, B, C, or D, each of which is occupying an
  otherwise open space), walls (#), and open space (.).

  For example:
  #{test_input()}

  The amphipods would like a method to organize every amphipod into side rooms
  so that each side room contains one type of amphipod and the types are sorted
  A-D going left to right, like this:

  #############
  #...........#
  ###A#B#C#D###
    #A#B#C#D#
    #########

  Amphipods can move up, down, left, or right so long as they are moving into
  an unoccupied open space. Each type of amphipod requires a different amount
  of energy to move one step: Amber amphipods require 1 energy per step, Bronze
  amphipods require 10 energy, Copper amphipods require 100, and Desert ones
  require 1000. The amphipods would like you to find a way to organize the
  amphipods that requires the least total energy.

  However, because they are timid and stubborn, the amphipods have some extra
  rules:

  - Amphipods will never stop on the space immediately outside any room. They
    can move into that space so long as they immediately continue moving.
    (Specifically, this refers to the four open spaces in the hallway that are
    directly above an amphipod starting position.)

  - Amphipods will never move from the hallway into a room unless that room is
    their destination room and that room contains no amphipods which do not also
    have that room as their own destination. If an amphipod's starting room is
    not its destination room, it can stay in that room until it leaves the room.
    (For example, an Amber amphipod will not move from the hallway into the right
    three rooms, and will only move into the leftmost room if that room is empty
    or if it only contains other Amber amphipods.)

  - Once an amphipod stops moving in the hallway, it will stay in that spot
    until it can move into a room. (That is, once any amphipod starts moving, any
    other amphipods currently in the hallway are locked in place and will not
    move again until they can move fully into a room.)


  In the above example, the amphipods can be organized using a minimum of 12521
  energy. One way to do this is shown below.

  Starting configuration:
  #############
  #...........#
  ###B#C#B#D###
    #A#D#C#A#
    #########

  One Bronze amphipod moves into the hallway, taking 4 steps and using 40
  energy:

  #############
  #...B.......#
  ###B#C#.#D###
    #A#D#C#A#
    #########

  The only Copper amphipod not in its side room moves there, taking 4 steps and
  using 400 energy:

  #############
  #...B.......#
  ###B#.#C#D###
    #A#D#C#A#
    #########

  A Desert amphipod moves out of the way, taking 3 steps and using 3000 energy,
  and then the Bronze amphipod takes its place, taking 3 steps and using 30
  energy:

  #############
  #.....D.....#
  ###B#.#C#D###
    #A#B#C#A#
    #########

  The leftmost Bronze amphipod moves to its room using 40 energy:

  #############
  #.....D.....#
  ###.#B#C#D###
    #A#B#C#A#
    #########

  Both amphipods in the rightmost room move into the hallway, using 2003 energy
  in total:

  #############
  #.....D.D.A.#
  ###.#B#C#.###
    #A#B#C#.#
    #########

  Both Desert amphipods move into the rightmost room using 7000 energy:

  #############
  #.........A.#
  ###.#B#C#D###
    #A#B#C#D#
    #########

  Finally, the last Amber amphipod moves into its room, using 8 energy:

  #############
  #...........#
  ###A#B#C#D###
    #A#B#C#D#
    #########

  What is the least energy required to organize the amphipods?

  ## Example
    iex> part_1(test_input())
    12521
  """
  def_solution part_1(stream_input) do
    stream_input
    |> parse()
    |> move_amphipods()
  end

  @doc ~S"""
  --- Part Two ---
  As you prepare to give the amphipods your solution, you notice that the
  diagram they handed you was actually folded up. As you unfold it, you
  discover an extra part of the diagram.

  Between the first and second lines of text that contain amphipod starting
  positions, insert the following lines:


    #D#C#B#A#
    #D#B#A#C#

  In this updated example, the least energy required to organize these amphipods is 44169:

  ## Example
    iex> part_2(test_input())
    44169
  """
  def_solution part_2(stream_input) do
    stream_input
    |> unfold_map()
    |> parse()
    |> move_amphipods()
  end

  def unfold_map(stream) do
    [a, b, c, f, g] = Enum.to_list(stream)
    d = "  #D#C#B#A#"
    e = "  #D#B#A#C#"

    [a, b, c, d, e, f, g]
  end

  def move_amphipods(states, max_iterations \\ nil),
    do: move_amphipods(states, %{score: nil, states: %{}}, max_iterations, 0)

  def move_amphipods([], %{score: score}, _, _), do: score

  def move_amphipods(states, %{score: score}, i, i), do: {states, score}

  def move_amphipods(states, meta, max_iterations, iterations) do
    {next_states, next_score} =
      for state <- states,
          {piece, current} <- movable_pieces(state),
          {destination, cost} <- get_moves(state, piece, current),
          updated_state = update_state(state, piece, current, destination, cost),
          reduce: {[], meta} do
        {next_states, meta} ->
          cond do
            updated_state.complete ->
              {next_states, Map.put(meta, :score, min(meta.score, updated_state.score))}

            not Map.has_key?(meta.states, updated_state.board) or
                Map.get(meta.states, updated_state.board) > updated_state.score ->
              {[updated_state | next_states],
               put_in(meta, [:states, updated_state.board], updated_state.score)}

            true ->
              {next_states, meta}
          end
      end

    move_amphipods(next_states, next_score, max_iterations, iterations + 1)
  end

  def movable_pieces(state) do
    state.pieces
    |> Enum.reject(fn {p, _} -> p == state.last_move end)
    |> Enum.reject(fn {piece, point} ->
      correct_door?(piece, point) and final_destination?(point, piece, state.board)
    end)
  end

  def update_state(state, piece, current, destination, cost) do
    board = state.board |> Map.merge(%{current => nil, destination => piece})
    pieces = state.pieces |> Map.put(piece, destination)
    score = state.score + cost
    # history = MapSet.put(state.history, :erlang.phash2(board, 1_000_000))
    complete = complete?(pieces)

    %{
      state
      | board: board,
        pieces: pieces,
        score: score,
        # history: history,
        complete: complete,
        last_move: piece
    }
  end

  def complete?(pieces) do
    Enum.all?(pieces, fn {piece, location} -> correct_door?(piece, location) end)
  end

  def get_moves(state, piece, {_, y1} = current) do
    if y1 == 1 do
      current
      |> get_open_spaces(state)
      |> Enum.filter(fn {point, _} ->
        correct_door?(piece, point) and final_destination?(point, piece, state.board)
      end)
    else
      current
      |> get_open_spaces(state)
      |> Enum.reject(fn {p, _} -> infront_of_door?(p, state.board) end)
      |> Enum.reject(fn {p, _} -> unavailable_room?(p, piece, state.board) end)
    end
    |> Enum.map(fn {destination, steps} ->
      {destination, base_score(piece) * steps}
    end)
  end

  def final_destination?({x, y}, {type, _id} = p, board) do
    below = {x, y + 1}

    if Map.has_key?(board, below) do
      match?({^type, _}, Map.get(board, below)) and final_destination?(below, p, board)
    else
      true
    end
  end

  def unavailable_room?({_, 1}, _piece, _board), do: false

  def unavailable_room?(point, piece, board) do
    not (correct_door?(piece, point) and final_destination?(point, piece, board))
  end

  def correct_door?(_, {_, 1}), do: false
  def correct_door?({"A", _}, {4, _}), do: true
  def correct_door?({"B", _}, {6, _}), do: true
  def correct_door?({"C", _}, {8, _}), do: true
  def correct_door?({"D", _}, {10, _}), do: true
  def correct_door?(_, _), do: false

  def base_score({"A", _}), do: 1
  def base_score({"B", _}), do: 10
  def base_score({"C", _}), do: 100
  def base_score({"D", _}), do: 1000

  @doc ~S"""
  ## Example
    iex> [%{board: board}] = test_input_2() |> Advent2021.stream() |> parse()
    iex> [infront_of_door?({4, 1}, board), infront_of_door?({5, 1}, board)]
    [true, false]
  """
  def infront_of_door?({x, y}, board) do
    Map.has_key?(board, {x - 1, y}) and Map.has_key?(board, {x + 1, y}) and
      Map.has_key?(board, {x, y + 1})
  end

  @doc ~S"""
  ## Example
    iex> [state] = test_input_2() |> Advent2021.stream() |> parse()
    iex> get_open_spaces({8, 2}, state)
    %{{8, 1} => 1, {9, 1} => 2, {10, 1} => 3, {11, 1} => 4, {12, 1} => 5}
  """
  def get_open_spaces({x, y}, state, steps \\ 1, all \\ %{}) do
    for x_prime <- (x - 1)..(x + 1),
        y_prime <- (y - 1)..(y + 1),
        x == x_prime or y == y_prime,
        point = {x_prime, y_prime},
        nil == Map.get(state.board, point, :unset),
        false == Map.has_key?(all, point),
        reduce: all do
      acc ->
        get_open_spaces(point, state, steps + 1, Map.put(acc, point, steps))
    end
  end

  def parse(stream) do
    for {line, y} <- Enum.with_index(stream),
        {cell, x} <- line |> String.split("") |> Enum.with_index(),
        point = {x, y},
        reduce: {%{}, %{}} do
      {board, pieces} ->
        case cell do
          "." ->
            {Map.put(board, point, nil), pieces}

          piece when piece in ["A", "B", "C", "D"] ->
            piece_id = {piece, Enum.filter(pieces, &match?({{^piece, _}, _}, &1)) |> Enum.count()}
            {Map.put(board, point, piece_id), Map.put(pieces, piece_id, point)}

          _ ->
            {board, pieces}
        end
    end
    |> then(fn {board, pieces} -> struct(Control, board: board, pieces: pieces) end)
    |> List.wrap()
  end

  def test_input do
    """
    #############
    #...........#
    ###B#C#B#D###
      #A#D#C#A#
      #########
    """
  end

  def test_input_2 do
    """
    #############
    #.....D.....#
    ###B#.#C#D###
      #A#B#C#A#
      #########
    """
  end

  def test_input_3 do
    """
    #############
    #...........#
    ###.#.#.#.###
      #.#.#.#A#
      #########
    """
  end

  def test_input_4 do
    """
    #############
    #.....D.....#
    ###B#.#C#D###
      #A#B#C#A#
      #########
    """
  end

  def test_input_5 do
    """
    #############
    #.....D.....#
    ###.#B#C#D###
      #A#B#C#A#
      #########
    """
  end

  def test_input_6 do
    """
    #############
    #.....D.D.A.#
    ###.#B#C#.###
      #A#B#C#.#
      #########
    """
  end

  def test_input_7 do
    """
    #############
    #.........A.#
    ###.#B#C#D###
      #A#B#C#D#
      #########
    """
  end

  def test_input_8 do
    """
    #############
    #...........#
    ###A#B#C#D###
      #A#B#C#D#
      #########
    """
  end
end
