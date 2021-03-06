defmodule Day14 do
  defmodule Control do
    defstruct template: [], rules: %{}, iteration: 0
  end

  import Advent2021

  @doc ~S"""
  --- Day 14: Extended Polymerization ---
  The incredible pressures at this depth are starting to put a strain on your
  submarine. The submarine has polymerization equipment that would produce
  suitable materials to reinforce the submarine, and the nearby
  volcanically-active caves should even have the necessary input elements in
  sufficient quantities.

  The submarine manual contains instructions for finding the optimal polymer
  formula; specifically, it offers a polymer template and a list of pair
  insertion rules (your puzzle input). You just need to work out what polymer
  would result after repeating the pair insertion process a few times.

  For example:
  #{test_input()}

  The first line is the polymer template - this is the starting point of the
  process.

  The following section defines the pair insertion rules. A rule like AB ->
  C means that when elements A and B are immediately adjacent, element C should
  be inserted between them. These insertions all happen simultaneously.

  So, starting with the polymer template NNCB, the first step simultaneously
  considers all three pairs:

  - The first pair (NN) matches the rule NN -> C, so element C is inserted
    between the first N and the second N.
  - The second pair (NC) matches the rule NC -> B, so element B is inserted
    between the N and the C.
  - The third pair (CB) matches the rule CB -> H, so element H is inserted
    between the C and the B.

  Note that these pairs overlap: the second element of one pair is the first
  element of the next pair. Also, because all pairs are considered
  simultaneously, inserted elements are not considered to be part of a pair
  until the next step.

  After the first step of this process, the polymer becomes NCNBCHB.

  Here are the results of a few steps using the above rules:
  Template:     NNCB
  After step 1: NCNBCHB
  After step 2: NBCCNBBBCBHCB

  After step 3: NBBBCNCCNBBNBNBBCHBHHBCHB
  After step 4: NBBNBNBBCCNBCNCCNBBNBBNBBBNBBNBBCBHCBHHNHCBBCBHCB

  This polymer grows quickly. After step 5, it has length 97; After step 10, it
  has length 3073. After step 10, B occurs 1749 times, C occurs 298 times, H
  occurs 161 times, and N occurs 865 times; taking the quantity of the most
  common element (B, 1749) and subtracting the quantity of the least common
  element (H, 161) produces 1749 - 161 = 1588.

  Apply 10 steps of pair insertion to the polymer template and find the most
  and least common elements in the result. What do you get if you take the
  quantity of the most common element and subtract the quantity of the least
  common element?

  ## Example
    iex> part_1(test_input())
    1588
  """
  def_solution part_1(stream_input) do
    stream_input
    |> parse()
    |> Stream.iterate(&replace/1)
    |> Enum.at(10)
    |> calculate_solution()
  end

  @doc ~S"""
  --- Part Two ---
  The resulting polymer isn't nearly strong enough to reinforce the submarine.
  You'll need to run more steps of the pair insertion process; a total of 40
  steps should do it.

  In the above example, the most common element is B (occurring 2192039569602
  times) and the least common element is H (occurring 3849876073 times);
  subtracting these produces 2188189693529.

  Apply 40 steps of pair insertion to the polymer template and find the most
  and least common elements in the result. What do you get if you take the
  quantity of the most common element and subtract the quantity of the least
  common element?

  ## Example
    iex> part_2(test_input())
    2188189693529
  """
  def_solution part_2(stream_input) do
    stream_input
    |> parse()
    |> Stream.iterate(&replace/1)
    |> Enum.at(40)
    |> calculate_solution()
  end

  def calculate_solution(%{template: template}) do
    template
    |> Enum.reduce(%{}, fn {[a, _b], x}, acc ->
      Map.update(acc, a, x, &(&1 + x))
    end)
    |> Map.update(?B, 1, &(&1 + 1))
    |> Enum.min_max_by(fn {_key, val} -> val end)
    |> then(fn {{_min_key, min_val}, {_max_key, max_val}} ->
      max_val - min_val
    end)
  end

  def replace(%{template: template, rules: rules} = control) do
    %{control | template: do_replace(template, rules)}
  end

  def do_replace(template, rules) do
    Enum.reduce(template, %{}, fn {[a, b] = pair, val}, next ->
      addition = rules[pair]

      next
      |> Map.update([a, addition], val, &(&1 + val))
      |> Map.update([addition, b], val, &(&1 + val))
    end)
  end

  def parse(stream_input) do
    stream_input
    |> Enum.map(fn
      <<a, b, " -> ", c>> -> {[a, b], c}
      other -> to_charlist(other)
    end)
    |> Enum.split(1)
    |> then(fn {[template], rules} ->
      struct(Control,
        template: Enum.frequencies(Enum.chunk_every(template, 2, 1, :discard)),
        rules: Map.new(rules)
      )
    end)
  end

  def test_input do
    """
    NNCB
    CH -> B
    HH -> N
    CB -> H
    NH -> C
    HB -> C
    HC -> B
    HN -> C
    NN -> C
    BH -> H
    NC -> B
    NB -> B
    BN -> B
    BB -> N
    BC -> B
    CC -> N
    CN -> C
    """
  end
end
