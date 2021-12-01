defmodule Advent2021Test do
  use ExUnit.Case

  File.cwd!()
  |> Path.join("/lib/puzzles")
  |> File.ls!()
  |> Enum.map(&String.replace(&1, ".ex", ""))
  |> Enum.map(fn day ->
    num = String.replace(day, "day_", "")
    module = Module.concat(["Day#{num}"])
    tag = String.to_atom(day)

    only =
      System.argv()
      |> Enum.filter(&String.contains?(&1, "part"))
      |> Enum.map(fn part ->
        {String.to_atom(part), 1}
      end)
      |> case do
        [] -> []
        list -> [only: list]
      end

    doctest module, [import: true, tags: tag] ++ only
  end)
end
