defmodule Day8 do
  import Advent2021

  @doc ~S"""
  --- Day 8: Seven Segment Search ---
  You barely reach the safety of the cave when the whale smashes into the cave
  mouth, collapsing it. Sensors indicate another exit to this cave at a much
  greater depth, so you have no choice but to press on.

  As your submarine slowly makes its way through the cave system, you notice
  that the four-digit seven-segment displays in your submarine are
  malfunctioning; they must have been damaged during the escape. You'll be in a
  lot of trouble without them, so you'd better figure out what's wrong.

  Each digit of a seven-segment display is rendered by turning on or off any of
  seven segments named a through g:

  0:      1:      2:      3:      4:
  aaaa    ....    aaaa    aaaa    ....
  b    c  .    c  .    c  .    c  b    c
  b    c  .    c  .    c  .    c  b    c
  ....    ....    dddd    dddd    dddd
  e    f  .    f  e    .  .    f  .    f
  e    f  .    f  e    .  .    f  .    f
  gggg    ....    gggg    gggg    ....

  5:      6:      7:      8:      9:
  aaaa    aaaa    aaaa    aaaa    aaaa
  b    .  b    .  .    c  b    c  b    c
  b    .  b    .  .    c  b    c  b    c
  dddd    dddd    ....    dddd    dddd
  .    f  e    f  .    f  e    f  .    f
  .    f  e    f  .    f  e    f  .    f
  gggg    gggg    ....    gggg    gggg

  if theres signal of lenght 2 and signal of lenght 3 (3 - 2) = a
  if theres signal of lenght 2 and signal of lenght 3 (3 - 2) = a

  So, to render a 1, only segments c and f would be turned on; the rest would
  be off. To render a 7, only segments a, c, and f would be turned on.

  The problem is that the signals which control the segments have been mixed up
  on each display. The submarine is still trying to display numbers by
  producing output on signal wires a through g, but those wires are connected
  to segments randomly. Worse, the wire/segment connections are mixed up
  separately for each four-digit display! (All of the digits within a display
  use the same connections, though.)

  So, you might know that only signal wires b and g are turned on, but that
  doesn't mean segments b and g are turned on: the only digit that uses two
  segments is 1, so it must mean segments c and f are meant to be on. With just
  that information, you still can't tell which wire (b/g) goes to which segment
  (c/f). For that, you'll need to collect more information.

  For each display, you watch the changing signals for a while, make a note of
  all ten unique signal patterns you see, and then write down a single four
  digit output value (your puzzle input). Using the signal patterns, you should
  be able to work out which pattern corresponds to which digit.

  For example, here is what you might see in a single entry in your notes:

  acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf

  (The entry is wrapped here to two lines so it fits; in your notes, it will
  all be on a single line.)

  Each entry consists of ten unique signal patterns, a | delimiter, and finally
  the four digit output value. Within an entry, the same wire/segment
  connections are used (but you don't know what the connections actually are).
  The unique signal patterns correspond to the ten different ways the submarine
  tries to render a digit using the current wire/segment connections. Because 7
  is the only digit that uses three segments, dab in the above example means
  that to render a 7, signal lines d, a, and b are on. Because 4 is the only
  digit that uses four segments, eafb means that to render a 4, signal lines e,
  a, f, and b are on.

  Using this information, you should be able to work out which combination of
  signal wires corresponds to each of the ten digits. Then, you can decode the
  four digit output value. Unfortunately, in the above example, all of the
  digits in the output value (cdfeb fcadb cdfeb cdbaf) use five segments and
  are more difficult to deduce.

  For now, focus on the easy digits. Consider this larger example:

  #{test_input}

  Because the digits 1, 4, 7, and 8 each use a unique number of segments, you
  should be able to tell which combinations of signals correspond to those
  digits. Counting only digits in the output values (the part after | on each
  line), in the above example, there are 26 instances of digits that use a
  unique number of segments (highlighted above).

  In the output values, how many times do digits 1, 4, 7, or 8 appear?

  ## Example
    iex> part_1(test_input())
    26
  """
  def_solution part_1(stream_input) do
    stream_input
    |> Stream.map(&String.replace(&1, ~r/.+ \| /, ""))
    |> Stream.map(&String.split/1)
    |> Stream.map(fn output_values ->
      Enum.count(output_values, fn string -> String.length(string) in [2, 3, 4, 7] end)
    end)
    |> Enum.sum()
  end

  @doc ~S"""
  --- Part Two ---
  Through a little deduction, you should now be able to determine the remaining
  digits. Consider again the first example above:

  acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf

  After some careful analysis, the mapping between signal wires and segments
  only make sense in the following configuration:

  dddd
  e    a
  e    a
  ffff
  g    b
  g    b
  cccc

  So, the unique signal patterns would correspond to the following digits:

  acedgfb: 8
  cdfbe: 5
  gcdfa: 2
  fbcad: 3
  dab: 7
  cefabd: 9
  cdfgeb: 6
  eafb: 4
  cagedb: 0
  ab: 1

  Then, the four digits of the output value can be decoded:

  cdfeb: 5
  fcadb: 3
  cdfeb: 5
  cdbaf: 3

  Therefore, the output value for this entry is 5353.

  Following this same process for each entry in the second, larger example
  above, the output value of each entry can be determined:

  fdgacbe cefdb cefbgd gcbe: 8394
  fcgedb cgb dgebacf gc: 9781
  cg cg fdcagb cbg: 1197
  efabcd cedba gadfec cb: 9361
  gecf egdcabf bgf bfgea: 4873
  gebdcfa ecba ca fadegcb: 8418
  cefg dcbef fcge gbcadfe: 4548
  ed bcgafe cdgba cbgef: 1625
  gbdfcae bgc cg cgb: 8717
  fgae cfgab fg bagce: 4315

  Adding all of the output values in this larger example produces 61229.

  For each entry, determine all of the wire/segment connections and decode the
  four-digit output values. What do you get if you add up all of the output
  values?

  ## Example
    iex> part_2(test_input())
    61229
  """

  def_solution part_2(stream_input) do
    parsed_lines = parse(stream_input)

    parsed_lines
    |> Enum.map(&decode/1)
    |> Enum.map(fn {_, output} ->
      output
      |> Enum.join()
      |> String.to_integer()
    end)
    |> Enum.sum()
  end

  @doc ~S"""
    iex> decode({~w/acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab/, ~w/cdfeb fcadb cdfeb cdbaf/})
    {[8, 5, 2, 3, 7, 9, 6, 4, 0, 1], [5, 3, 5, 3]}
  """
  def decode({signals, output}) do
    all = signals ++ output

    all
    |> decode()
  end

  def decode(list) do
    one = Enum.find(list, &(String.length(&1) == 2))
    four = Enum.find(list, &(String.length(&1) == 4))
    seven = Enum.find(list, &(String.length(&1) == 3))

    nine =
      if four do
        Enum.find(list, fn string ->
          String.length(string) == 6 and
            String.codepoints(four) -- String.codepoints(string) == []
        end)
      end

    zero =
      if one && nine do
        Enum.find(list, fn string ->
          string != nine and
            String.length(string) == 6 and
            String.codepoints(one) -- String.codepoints(string) == []
        end)
      end

    six =
      if one && nine do
        Enum.find(list, fn string ->
          string != nine and
            String.length(string) == 6 and
            length(String.codepoints(one) -- String.codepoints(string)) == 1
        end)
      end

    %{}
    |> maybe_update(one && seven, &get_a(&1, one, seven))
    |> maybe_update(four && seven && nine, &get_g(&1, four, seven, nine))
    |> maybe_update(nine, &get_e(&1, nine))
    |> maybe_update(one && six, &get_c_and_f(&1, one, six))
    |> maybe_update(four && zero, &get_d(&1, four, zero))
    |> try_solve(list)
  end

  defp try_solve(decoder, list) do
    solved = Map.keys(decoder)
    unsolved = ~w/a b c d e f g/ -- solved

    mapped = Map.values(decoder)
    unmapped = ~w/a b c d e f g/ -- mapped
    mappings = gen_mappings(unmapped)

    case unsolved do
      [] ->
        [decoder]

      _ ->
        Enum.map(mappings, fn mapping ->
          Enum.zip(unsolved, mapping)
          |> Map.new()
          |> Map.merge(decoder)
        end)
    end
    |> Enum.find_value(fn potential_decoder ->
      Enum.reduce_while(list, [], fn encoded, acc ->
        key =
          encoded
          |> String.codepoints()
          |> Enum.map(&potential_decoder[&1])
          |> Enum.sort()

        if res = signals_to_numbers()[key] do
          {:cont, [res | acc]}
        else
          {:halt, nil}
        end
      end)
    end)
    |> Enum.reverse()
    |> Enum.split(-4)
  end

  @doc ~S"""
    iex> gen_mappings([1, 2, 3])
    [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]]
  """
  def gen_mappings([]), do: [[]]

  def gen_mappings(list) do
    list
    |> Enum.flat_map(fn item ->
      mappings = gen_mappings(list -- [item])

      Enum.map(mappings, fn m -> [item | m] end)
    end)
  end

  defp get_d(map, four, zero) do
    [d] = String.codepoints(four) -- String.codepoints(zero)
    Map.put(map, d, "d")
  end

  defp get_c_and_f(map, one, six) do
    [c] = String.codepoints(one) -- String.codepoints(six)
    [f] = String.codepoints(one) -- [c]

    map
    |> Map.put(c, "c")
    |> Map.put(f, "f")
  end

  defp get_e(map, nine) do
    [e] = ~w/a b c d e f g/ -- String.codepoints(nine)
    Map.put(map, e, "e")
  end

  defp get_g(map, four, seven, nine) do
    [g] = String.codepoints(nine) -- (String.codepoints(four) ++ String.codepoints(seven))
    Map.put(map, g, "g")
  end

  defp get_a(map, one, seven) do
    [a] = String.codepoints(seven) -- String.codepoints(one)
    Map.put(map, a, "a")
  end

  defp maybe_update(map, bool, fun) do
    if bool, do: fun.(map), else: map
  end

  defp parse(stream_input) do
    stream_input
    |> Stream.map(&String.split(&1, [" ", " | "]))
    |> Stream.map(&Enum.split(&1, -4))
    |> Enum.to_list()
  end

  defp signals_to_numbers do
    %{
      ~w/a b c e f g/ => 0,
      ~w/c f/ => 1,
      ~w/a c d e g/ => 2,
      ~w/a c d f g/ => 3,
      ~w/b c d f/ => 4,
      ~w/a b d f g/ => 5,
      ~w/a b d e f g/ => 6,
      ~w/a c f/ => 7,
      ~w/a b c d e f g/ => 8,
      ~w/a b c d f g/ => 9
    }
  end

  def test_input do
    """
    be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
    edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
    fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
    fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
    aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
    fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
    dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
    bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
    egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
    gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce
    """
  end
end

