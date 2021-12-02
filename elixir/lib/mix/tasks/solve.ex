defmodule Mix.Tasks.Solve do
  @moduledoc """
    `mix solve 1 1`
  """

  use Mix.Task

  @shortdoc "Solve a problem by day and part"
  def run([day, part | rest]) do
    {time, result} = :timer.tc(fn -> Advent2021.solve(day, part, rest) end)

    IO.puts([
      IO.ANSI.green(),
      "AOC Day #{day} / Part #{part}\n",
      "Results : #{result}\n",
      "Executed in : #{time}ms\n",
      IO.ANSI.reset()
    ])
  end
end
