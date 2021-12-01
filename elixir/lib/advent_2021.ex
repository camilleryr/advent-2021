defmodule Advent2021 do
  defmacro def_solution({name, _env, args}, do: block) do
    defp_name = String.to_atom("__#{name}__")

    quote do
      def unquote(name)(unquote_splicing(args)) do
        stream =
          unquote(args)
          |> List.first()
          |> Advent2021.stream()

        apply(__MODULE__, unquote(defp_name), [stream | unquote(Enum.drop(args, 1))])
      end

      @doc false
      def unquote(defp_name)(unquote_splicing(args)), do: unquote(block)
    end
  end

  def stream(path_or_string) do
    if String.ends_with?(path_or_string, ".txt") do
      File.stream!(path_or_string)
    else
      stream_string(path_or_string)
    end
    |> Stream.flat_map(fn
      "\n" -> []
      line -> [String.trim(line, "\n")]
    end)
  end

  defp stream_string(string) do
    with {:ok, stream} <- StringIO.open(string) do
      IO.binstream(stream, :line)
    end
  end

  def solve(day, part, additional_args \\ []) do
    module = Module.concat(["Day#{day}"])
    fun = String.to_atom("part_#{part}")
    input_file = "./lib/input/day_#{day}.txt"

    apply(module, fun, [input_file | additional_args])
  end
end
