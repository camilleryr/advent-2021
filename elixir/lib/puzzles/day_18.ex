defmodule Day18 do
  import Advent2021

  @doc ~S"""
  --- Day 18: Snailfish ---
  You descend into the ocean trench and encounter some snailfish. They say they
  saw the sleigh keys! They'll even tell you which direction the keys went if
  you help one of the smaller snailfish with his math homework.

  Snailfish numbers aren't like regular numbers. Instead, every snailfish
  number is a pair - an ordered list of two elements. Each element of the pair
  can be either a regular number or another pair.

  Pairs are written as [x,y], where x and y are the elements within the pair.

  Here are some example snailfish numbers, one snailfish number per line:

  [1,2]
  [[1,2],3]
  [9,[8,7]]
  [[1,9],[8,5]]
  [[[[1,2],[3,4]],[[5,6],[7,8]]],9]
  [[[9,[3,8]],[[0,9],6]],[[[3,7],[4,9]],3]]
  [[[[1,3],[5,3]],[[1,3],[8,7]]],[[[4,9],[6,9]],[[8,2],[7,3]]]]

  This snailfish homework is about addition. To add two snailfish numbers, form
  a pair from the left and right parameters of the addition operator. For
  example, [1,2] + [[3,4],5] becomes [[1,2],[[3,4],5]].

  There's only one problem: snailfish numbers must always be reduced, and the
  process of adding two snailfish numbers can result in snailfish numbers that
  need to be reduced.

  To reduce a snailfish number, you must repeatedly do the first action in this
  list that applies to the snailfish number:

  - If any pair is nested inside four pairs, the leftmost such pair explodes.
  - If any regular number is 10 or greater, the leftmost such regular number splits.

  Once no action in the above list applies, the snailfish number is reduced.

  During reduction, at most one action applies, after which the process returns
  to the top of the list of actions. For example, if split produces a pair that
  meets the explode criteria, that pair explodes before other splits occur.

  To explode a pair, the pair's left value is added to the first regular number
  to the left of the exploding pair (if any), and the pair's right value is
  added to the first regular number to the right of the exploding pair (if
  any). Exploding pairs will always consist of two regular numbers. Then, the
  entire exploding pair is replaced with the regular number 0.

  Here are some examples of a single explode action:

  - [[[[[9,8],1],2],3],4] becomes [[[[0,9],2],3],4] (the 9 has no regular
      number to its left, so it is not added to any regular number).

  - [7,[6,[5,[4,[3,2]]]]] becomes [7,[6,[5,[7,0]]]] (the 2 has no regular
      number to its right, and so it is not added to any regular number).

  - [[6,[5,[4,[3,2]]]],1] becomes [[6,[5,[7,0]]],3].

  - [[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]] becomes
      [[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]] (the pair [3,2] is unaffected because the
      pair [7,3] is further to the left; [3,2] would explode on the next action).

  - [[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]] becomes [[3,[2,[8,0]]],[9,[5,[7,0]]]].

  To split a regular number, replace it with a pair; the left element of the
  pair should be the regular number divided by two and rounded down, while the
  right element of the pair should be the regular number divided by two and
  rounded up. For example, 10 becomes [5,5], 11 becomes [5,6], 12 becomes
  [6,6], and so on.

  Here is the process of finding the reduced result of
  [[[[4,3],4],4],[7,[[8,4],9]]] + [1,1]:

  after addition: [[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]]
  after explode:  [[[[0,7],4],[7,[[8,4],9]]],[1,1]]
  after explode:  [[[[0,7],4],[15,[0,13]]],[1,1]]
  after split:    [[[[0,7],4],[[7,8],[0,13]]],[1,1]]
  after split:    [[[[0,7],4],[[7,8],[0,[6,7]]]],[1,1]]
  after explode:  [[[[0,7],4],[[7,8],[6,0]]],[8,1]]

  Once no reduce actions apply, the snailfish number that remains is the actual
  result of the addition operation: [[[[0,7],4],[[7,8],[6,0]]],[8,1]].

  The homework assignment involves adding up a list of snailfish numbers (your
  puzzle input). The snailfish numbers are each listed on a separate line. Add
  the first snailfish number and the second, then add that result and the
  third, then add that result and the fourth, and so on until all numbers in
  the list have been used once.

  For example, the final sum of this list is [[[[1,1],[2,2]],[3,3]],[4,4]]:
  [1,1]
  [2,2]
  [3,3]
  [4,4]

  The final sum of this list is [[[[3,0],[5,3]],[4,4]],[5,5]]:
  [1,1]
  [2,2]
  [3,3]
  [4,4]
  [5,5]

  The final sum of this list is [[[[5,0],[7,4]],[5,5]],[6,6]]:
  [1,1]
  [2,2]
  [3,3]
  [4,4]
  [5,5]
  [6,6]

  Here's a slightly larger example:
  #{test_input_2()}

  The final sum [[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]] is found
  after adding up the above snailfish numbers:

  [[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]
  + [7,[[[3,7],[4,3]],[[6,3],[8,8]]]]
  = [[[[4,0],[5,4]],[[7,7],[6,0]]],[[8,[7,7]],[[7,9],[5,0]]]]

  [[[[4,0],[5,4]],[[7,7],[6,0]]],[[8,[7,7]],[[7,9],[5,0]]]]
  + [[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]]
  = [[[[6,7],[6,7]],[[7,7],[0,7]]],[[[8,7],[7,7]],[[8,8],[8,0]]]]

  [[[[6,7],[6,7]],[[7,7],[0,7]]],[[[8,7],[7,7]],[[8,8],[8,0]]]]
  + [[[[2,4],7],[6,[0,5]]],[[[6,8],[2,8]],[[2,1],[4,5]]]]
  = [[[[7,0],[7,7]],[[7,7],[7,8]]],[[[7,7],[8,8]],[[7,7],[8,7]]]]

  [[[[7,0],[7,7]],[[7,7],[7,8]]],[[[7,7],[8,8]],[[7,7],[8,7]]]]
  + [7,[5,[[3,8],[1,4]]]]
  = [[[[7,7],[7,8]],[[9,5],[8,7]]],[[[6,8],[0,8]],[[9,9],[9,0]]]]

  [[[[7,7],[7,8]],[[9,5],[8,7]]],[[[6,8],[0,8]],[[9,9],[9,0]]]]
  + [[2,[2,2]],[8,[8,1]]]
  = [[[[6,6],[6,6]],[[6,0],[6,7]]],[[[7,7],[8,9]],[8,[8,1]]]]

  [[[[6,6],[6,6]],[[6,0],[6,7]]],[[[7,7],[8,9]],[8,[8,1]]]]
  + [2,9]
  = [[[[6,6],[7,7]],[[0,7],[7,7]]],[[[5,5],[5,6]],9]]

  [[[[6,6],[7,7]],[[0,7],[7,7]]],[[[5,5],[5,6]],9]]
  + [1,[[[9,3],9],[[9,0],[0,7]]]]
  = [[[[7,8],[6,7]],[[6,8],[0,8]]],[[[7,7],[5,0]],[[5,5],[5,6]]]]

  [[[[7,8],[6,7]],[[6,8],[0,8]]],[[[7,7],[5,0]],[[5,5],[5,6]]]]
  + [[[5,[7,4]],7],1]
  = [[[[7,7],[7,7]],[[8,7],[8,7]]],[[[7,0],[7,7]],9]]

  [[[[7,7],[7,7]],[[8,7],[8,7]]],[[[7,0],[7,7]],9]]
  + [[[[4,2],2],6],[8,7]]
  = [[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]

  To check whether it's the right answer, the snailfish teacher only checks the
  magnitude of the final sum. The magnitude of a pair is 3 times the magnitude
  of its left element plus 2 times the magnitude of its right element. The
  magnitude of a regular number is just that number.

  For example, the magnitude of [9,1] is 3*9 + 2*1 = 29; the magnitude of [1,9]
  is 3*1 + 2*9 = 21. Magnitude calculations are recursive: the magnitude of
  [[9,1],[1,9]] is 3*29 + 2*21 = 129.

  Here are a few more magnitude examples:

  - [[1,2],[[3,4],5]] becomes 143.
  - [[[[0,7],4],[[7,8],[6,0]]],[8,1]] becomes 1384.
  - [[[[1,1],[2,2]],[3,3]],[4,4]] becomes 445.
  - [[[[3,0],[5,3]],[4,4]],[5,5]] becomes 791.
  - [[[[5,0],[7,4]],[5,5]],[6,6]] becomes 1137.
  - [[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]] becomes 3488.

  So, given this example homework assignment:
  #{test_input()}

  The final sum is:
  [[[[6,6],[7,6]],[[7,7],[7,0]]],[[[7,7],[7,7]],[[7,8],[9,9]]]]

  The magnitude of this final sum is 4140.

  Add up all of the snailfish numbers from the homework assignment in the order
  they appear. What is the magnitude of the final sum?

  ## Example
    iex> part_1(test_input())
    4140
  """
  def_solution part_1(stream_input) do
    stream_input
    |> parse
    |> Enum.reduce(&add(&2, &1))
    |> get_magnitude()
  end

  @doc ~S"""
  --- Part Two ---
  You notice a second question on the back of the homework assignment:

  What is the largest magnitude you can get from adding only two of the
  snailfish numbers?

  Note that snailfish addition is not commutative - that is, x + y and y + x
  can produce different results.

  Again considering the last example homework assignment above:
  #{test_input()}

  The largest magnitude of the sum of any two snailfish numbers in this list is
  3993. This is the magnitude of [[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]] +
  [[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]], which reduces to
  [[[[7,8],[6,6]],[[6,0],[7,7]]],[[[7,8],[8,8]],[[7,9],[0,6]]]].

  What is the largest magnitude of any sum of two different snailfish numbers
  from the homework assignment?

  ## Example
    iex> part_2(test_input())
    3993
  """
  def_solution part_2(stream_input) do
    numbers = stream_input |> parse() |> Enum.to_list()

    for x <- numbers, y <- numbers, x != y do
      x |> add(y) |> get_magnitude()
    end
    |> Enum.max()
  end

  def parse(stream_input) do
    Stream.map(stream_input, fn line ->
      {term, _} = Code.eval_string(line)
      term
    end)
  end

  @doc ~S"""
  ## Example
    iex> add([[[[4,3],4],4],[7,[[8,4],9]]], [1,1])
    [[[[0,7],4],[[7,8],[6,0]]],[8,1]]

    iex> add([[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]], [7,[[[3,7],[4,3]],[[6,3],[8,8]]]])
    [[[[4,0],[5,4]],[[7,7],[6,0]]],[[8,[7,7]],[[7,9],[5,0]]]]

    iex> add([[[[4,0],[5,4]],[[7,7],[6,0]]],[[8,[7,7]],[[7,9],[5,0]]]], [[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]])
    [[[[6,7],[6,7]],[[7,7],[0,7]]],[[[8,7],[7,7]],[[8,8],[8,0]]]]

    iex> add([[[[6,7],[6,7]],[[7,7],[0,7]]],[[[8,7],[7,7]],[[8,8],[8,0]]]], [[[[2,4],7],[6,[0,5]]],[[[6,8],[2,8]],[[2,1],[4,5]]]])
    [[[[7,0],[7,7]],[[7,7],[7,8]]],[[[7,7],[8,8]],[[7,7],[8,7]]]]

    iex> add([[[[7,0],[7,7]],[[7,7],[7,8]]],[[[7,7],[8,8]],[[7,7],[8,7]]]], [7,[5,[[3,8],[1,4]]]])
    [[[[7,7],[7,8]],[[9,5],[8,7]]],[[[6,8],[0,8]],[[9,9],[9,0]]]]

    iex> add([[[[7,7],[7,8]],[[9,5],[8,7]]],[[[6,8],[0,8]],[[9,9],[9,0]]]], [[2,[2,2]],[8,[8,1]]])
    [[[[6,6],[6,6]],[[6,0],[6,7]]],[[[7,7],[8,9]],[8,[8,1]]]]

    iex> add([[[[6,6],[6,6]],[[6,0],[6,7]]],[[[7,7],[8,9]],[8,[8,1]]]], [2,9])
    [[[[6,6],[7,7]],[[0,7],[7,7]]],[[[5,5],[5,6]],9]]

    iex> add([[[[6,6],[7,7]],[[0,7],[7,7]]],[[[5,5],[5,6]],9]], [1,[[[9,3],9],[[9,0],[0,7]]]])
    [[[[7,8],[6,7]],[[6,8],[0,8]]],[[[7,7],[5,0]],[[5,5],[5,6]]]]

    iex> add([[[[7,8],[6,7]],[[6,8],[0,8]]],[[[7,7],[5,0]],[[5,5],[5,6]]]], [[[5,[7,4]],7],1])
    [[[[7,7],[7,7]],[[8,7],[8,7]]],[[[7,0],[7,7]],9]]

    iex> add([[[[7,7],[7,7]],[[8,7],[8,7]]],[[[7,0],[7,7]],9]], [[[[4,2],2],6],[8,7]])
    [[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]
  """
  def add(n1, n2) do
    n1
    |> do_add(n2)
    |> reduce()
  end

  def reduce(n) do
    with ^n <- explode(n),
         ^n <- split(n) do
      n
    else
      updated -> reduce(updated)
    end
  end

  @doc ~S"""
  ## Example
    iex> get_magnitude([[9,1],[1,9]])
    129

    iex> get_magnitude([[[[0,7],4],[[7,8],[6,0]]],[8,1]])
    1384

    iex> get_magnitude([[[[1,1],[2,2]],[3,3]],[4,4]])
    445

    iex> get_magnitude([[[[3,0],[5,3]],[4,4]],[5,5]])
    791

    iex> get_magnitude([[[[5,0],[7,4]],[5,5]],[6,6]])
    1137

    iex> get_magnitude([[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]])
    3488
  """
  def get_magnitude(n) when is_integer(n), do: n

  def get_magnitude([left, right]) do
    3 * get_magnitude(left) + 2 * get_magnitude(right)
  end

  @doc ~S"""
  ## Example
    iex> do_add([1,2], [[3,4],5])
    [[1,2],[[3,4],5]]

    iex> do_add([[[[4,3],4],4],[7,[[8,4],9]]], [1,1])
    [[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]]
  """
  def do_add(n1, n2) do
    [n1, n2]
  end

  @doc ~S"""
  ## Example
    iex> explode([[[[[9,8],1],2],3],4])
    [[[[0,9],2],3],4]

    iex> explode([7,[6,[5,[4,[3,2]]]]])
    [7,[6,[5,[7,0]]]]

    iex> explode([[6,[5,[4,[3,2]]]],1])
    [[6,[5,[7,0]]],3]

    iex> explode([[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]])
    [[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]

    iex> explode([[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]])
    [[3,[2,[8,0]]],[9,[5,[7,0]]]]
  """
  def explode(n) do
    case explode(n, 0) do
      {_, exploded, _} -> exploded
      _ -> n
    end
  end

  def explode([a, b], 4) do
    {a, 0, b}
  end

  def explode([a, b], level) do
    cond do
      res = explode(a, level + 1) ->
        {aa, n, ab} = res
        {aa, [n, merge(ab, b)], 0}

      res = explode(b, level + 1) ->
        {ba, n, bb} = res
        {0, [merge(a, ba), n], bb}

      true ->
        nil
    end
  end

  def explode(_n, _level), do: false

  def merge([a, b], n), do: [a, merge(b, n)]
  def merge(n, [a, b]), do: [merge(n, a), b]
  def merge(a, b), do: a + b

  @doc ~S"""
  ## Example
    iex> split([[[[0,7],4],[15,[0,13]]],[1,1]])
    [[[[0,7],4],[[7,8],[0,13]]],[1,1]]

    iex> split([[[[0,7],4],[[7,8],[0,13]]],[1,1]])
    [[[[0,7],4],[[7,8],[0,[6,7]]]],[1,1]]
  """
  def split(n) when is_integer(n) and n >= 10 do
    half = n / 2
    [floor(half), ceil(half)]
  end

  def split([head | tail]) do
    case split(head) do
      ^head -> [head | split(tail)]
      was_split -> [was_split | tail]
    end
  end

  def split(x), do: x

  def test_input do
    """
    [[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
    [[[5,[2,8]],4],[5,[[9,9],0]]]
    [6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
    [[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
    [[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
    [[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
    [[[[5,4],[7,7]],8],[[8,3],8]]
    [[9,3],[[9,9],[6,[4,9]]]]
    [[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
    [[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]
    """
  end

  def test_input_2 do
    """
    [[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]
    [7,[[[3,7],[4,3]],[[6,3],[8,8]]]]
    [[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]]
    [[[[2,4],7],[6,[0,5]]],[[[6,8],[2,8]],[[2,1],[4,5]]]]
    [7,[5,[[3,8],[1,4]]]]
    [[2,[2,2]],[8,[8,1]]]
    [2,9]
    [1,[[[9,3],9],[[9,0],[0,7]]]]
    [[[5,[7,4]],7],1]
    [[[[4,2],2],6],[8,7]]
    """
  end
end

