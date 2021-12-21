defmodule Day21 do
  defprotocol Dice do
    def roll(data)
  end

  defmodule DirecDie do
    defstruct value: nil

    defimpl Dice, for: DirecDie do
      def roll(%{value: value}) when value in 3..9 do
        {value, %DirecDie{}}
      end
    end
  end

  defmodule OneHundredSidedDie do
    defstruct rolls: 0

    defimpl Dice, for: OneHundredSidedDie do
      def roll(%{rolls: rolls} = one_hundred_sided_die) do
        next = rolls + 1
        value = next * 3 + 3
        {value, %{one_hundred_sided_die | rolls: rolls + 3}}
      end
    end
  end

  defmodule Control do
    defstruct players: %{}, roll: 0, winner: nil, turn: 0, player_total: 0, dice: nil

    def add_dice(control, dice), do: %{control | dice: dice}
  end

  defmodule Player do
    defstruct position: 0, score: 0

    def update(%{position: position, score: score} = p, spaces) do
      next_position = Day21.get_rem(position + spaces, 10)
      next_score = score + next_position

      %{p | position: next_position, score: next_score}
    end
  end

  import Advent2021

  @doc ~S"""
  --- Day 21: Dirac Dice ---

  There's not much to do as you slowly descend to the bottom of the ocean. The
  submarine computer challenges you to a nice game of Dirac Dice.

  This game consists of a single die, two pawns, and a game board with a
  circular track containing ten spaces marked 1 through 10 clockwise. Each
  player's starting space is chosen randomly (your puzzle input). Player 1 goes
  first.

  Players take turns moving. On each player's turn, the player rolls the die
  three times and adds up the results. Then, the player moves their pawn that
  many times forward around the track (that is, moving clockwise on spaces in
  order of increasing value, wrapping back around to 1 after 10). So, if a
  player is on space 7 and they roll 2, 2, and 1, they would move forward 5
  times, to spaces 8, 9, 10, 1, and finally stopping on 2.

  After each player moves, they increase their score by the value of the space
  their pawn stopped on. Players' scores start at 0. So, if the first player
  starts on space 7 and rolls a total of 5, they would stop on space 2 and add
  2 to their score (for a total score of 2). The game immediately ends as a win
  for any player whose score reaches at least 1000.

  Since the first game is a practice game, the submarine opens a compartment
  labeled deterministic dice and a 100-sided die falls out. This die always
  rolls 1 first, then 2, then 3, and so on up to 100, after which it starts
  over at 1 again. Play using this die.

  For example, given these starting positions:
  #{test_input()}

  This is how the game would go:

  - Player 1 rolls 1+2+3 and moves to space 10 for a total score of 10.
  - Player 2 rolls 4+5+6 and moves to space 3 for a total score of 3.
  - Player 1 rolls 7+8+9 and moves to space 4 for a total score of 14.
  - Player 2 rolls 10+11+12 and moves to space 6 for a total score of 9.
  - Player 1 rolls 13+14+15 and moves to space 6 for a total score of 20.
  - Player 2 rolls 16+17+18 and moves to space 7 for a total score of 16.
  - Player 1 rolls 19+20+21 and moves to space 6 for a total score of 26.
  - Player 2 rolls 22+23+24 and moves to space 6 for a total score of 22.
  ...after many turns...

  - Player 2 rolls 82+83+84 and moves to space 6 for a total score of 742.
  - Player 1 rolls 85+86+87 and moves to space 4 for a total score of 990.
  - Player 2 rolls 88+89+90 and moves to space 3 for a total score of 745.
  - Player 1 rolls 91+92+93 and moves to space 10 for a final score, 1000.

  Since player 1 has at least 1000 points, player 1 wins and the game ends. At
  this point, the losing player had 745 points and the die had been rolled a
  total of 993 times; 745 * 993 = 739785.

  Play a practice game using the deterministic 100-sided die. The moment either
  player wins, what do you get if you multiply the score of the losing player
  by the number of times the die was rolled during the game?


  ## Example
    iex> part_1(test_input())
    739785
  """
  def_solution part_1(stream_input) do
    stream_input
    |> parse()
    |> Control.add_dice(%OneHundredSidedDie{})
    |> play_dirac_dice(1000)
    |> calculate_solution()
  end

  def play_dirac_dice(control, point_threshold) do
    case do_play_dirac_dice(control, point_threshold) do
      %{winner: winner} = game_over when is_integer(winner) -> game_over
      continue -> play_dirac_dice(continue, point_threshold)
    end
  end

  def calculate_solution(control) do
    {_, %{score: looser}} = Enum.min_by(control.players, fn {_idx, player} -> player.score end)
    looser * control.dice.rolls
  end

  @potential_dice_roll_mappings %{3 => 1, 4 => 3, 5 => 6, 6 => 7, 7 => 6, 8 => 3, 9 => 1}

  @doc ~S"""
  --- Part Two ---
  Now that you're warmed up, it's time to play the real game.

  A second compartment opens, this time labeled Dirac dice. Out of it falls a
  single three-sided die.

  As you experiment with the die, you feel a little strange. An informational
  brochure in the compartment explains that this is a quantum die: when you
  roll it, the universe splits into multiple copies, one copy for each possible
  outcome of the die. In this case, rolling the die always splits the universe
  into three copies: one where the outcome of the roll was 1, one where it was
  2, and one where it was 3.

  The game is played the same as before, although to prevent things from
  getting too far out of hand, the game now ends when either player's score
  reaches at least 21.

  Using the same starting positions as in the example above, player 1 wins in
  444356092776315 universes, while player 2 merely wins in 341960390180808
  universes.

  Using your given starting positions, determine every possible outcome. Find
  the player that wins in more universes; in how many universes does that
  player win?

  ## Example
    iex> part_2(test_input())
    444356092776315
  """
  def_solution part_2(stream_input) do
    stream_input
    |> parse()
    |> play_multi_dimentional_dice(21)
    |> calculate_solution_2()
  end

  def calculate_solution_2(complete_games) do
    complete_games
    |> Enum.group_by(fn {%{winner: winner}, _} -> winner end, fn {_, val} -> val end)
    |> Enum.map(fn {winner, universes} -> {winner, Enum.sum(universes)} end)
    |> Enum.max_by(fn {_, total_universes} -> total_universes end)
    |> elem(1)
  end

  def play_multi_dimentional_dice(initial_game_state, point_threshold) do
    play_multi_dimentional_dice(%{initial_game_state => 1}, %{}, point_threshold)
  end

  def play_multi_dimentional_dice(in_progress, complete, _point_threshold)
      when map_size(in_progress) == 0,
      do: complete

  def play_multi_dimentional_dice(in_progress, complete, point_threshold) do
    {next_in_progress, additional_complete} =
      for {game_state, universes} <- in_progress,
          {dice_value, new_universes} <- @potential_dice_roll_mappings,
          reduce: {%{}, %{}} do
        {continue, winning} ->
          updated_game_state =
            game_state
            |> Control.add_dice(%DirecDie{value: dice_value})
            |> do_play_dirac_dice(point_threshold)

          next_val = universes * new_universes

          case updated_game_state do
            %{winner: w} when is_integer(w) ->
              {continue, Map.update(winning, updated_game_state, next_val, &(&1 + next_val))}

            _ ->
              {Map.update(continue, updated_game_state, next_val, &(&1 + next_val)), winning}
          end
      end

    next_complete = Map.merge(complete, additional_complete, fn _, v1, v2 -> v1 + v2 end)

    play_multi_dimentional_dice(next_in_progress, next_complete, point_threshold)
  end

  def do_play_dirac_dice(control, point_threshold) do
    turn = control.turn + 1
    current_player = get_rem(turn, control.player_total)
    {roll_total, next_dice} = Dice.roll(control.dice)
    updated_player = Player.update(control.players[current_player], roll_total)
    winner = if(updated_player.score >= point_threshold, do: current_player)

    %{
      control
      | players: Map.put(control.players, current_player, updated_player),
        turn: turn,
        dice: next_dice,
        winner: winner
    }
  end

  def parse(stream_input) do
    stream_input
    |> Stream.with_index(1)
    |> Enum.reduce(%Control{}, fn {line, index}, acc ->
      position =
        line
        |> String.replace(~r/.+: /, "")
        |> String.to_integer()

      %{acc | players: Map.put(acc.players, index, %Player{position: position})}
    end)
    |> then(fn control ->
      %{control | player_total: map_size(control.players)}
    end)
  end

  def test_input do
    """
    Player 1 starting position: 4
    Player 2 starting position: 8
    """
  end

  def get_rem(x, y) do
    case rem(x, y) do
      0 -> y
      other -> other
    end
  end
end

# total -> 3 roll combos -> universes
# 3 - 1 - 3
# 4 - 3 - 9
# 5 - 6 - 18
# 6 - 7 - 21
# 7 - 6 - 18
# 8 - 3 - 9
# 9 - 1 - 3
#

