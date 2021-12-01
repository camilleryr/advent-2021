defmodule Mix.Tasks.Solve do
  @shortdoc "Solve a problem by day and part"
  @moduledoc """
    `mix solve 1 1`
  """

  use Mix.Task

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
