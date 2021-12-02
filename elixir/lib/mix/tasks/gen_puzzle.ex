defmodule Mix.Tasks.GenPuzzle do
  @moduledoc """
    `mix gne_puzzle 1`
  """

  use Mix.Task

  @shortdoc "Solve a problem by day and part"
  def run([day]) do
    IO.puts([
      IO.ANSI.yellow(),
      "Generating input and puzzle files for AOC day #{day}\n",
      "Please copy puzzle input to system clipboard and press return to continue\n",
      IO.ANSI.reset()
    ])

    IO.read(:line)

    gen_input_file(day)
    gen_puzzle_file(day)
  end

  defp gen_puzzle_file(day) do
    """
    echo '#{puzzle_template(day)}' > ./lib/puzzles/day_#{day}.ex
    """
    |> String.to_charlist()
    |> :os.cmd()
  end

  defp gen_input_file(day) do
    """
    pbpaste > ../input/day_#{day}.txt
    """
    |> String.to_charlist()
    |> :os.cmd()
  end

  defp puzzle_template(day) do
    ~s"""
    defmodule Day#{day} do
      import Advent2021

      @doc ~S\"\"\"
      ## Example

        iex> part_1()
      \"\"\"
      def_solution part_1(stream_input) do
      end
    end
    """
    |> String.trim("\n")
  end
end
