defmodule Day24 do
  defmodule ALU do
    defstruct inputs: [], program: [], program_length: 0, pointer: 0, w: 0, x: 0, y: 0, z: 0

    def run_program(state) do
      if state.pointer == state.program_length do
        state
      else
        {instruction, args} = Enum.at(state.program, state.pointer)

        __MODULE__
        |> apply(instruction, [state | args])
        |> then(fn updated_state ->
          %{updated_state | pointer: updated_state.pointer + 1}
        end)
        # |> tap(fn s -> IO.inspect({s.w, s.x, s.y, s.z}, label: inspect({instruction, args})) end)
        |> run_program()
      end
    end

    def set_input(state, input) do
      %{state | inputs: List.wrap(input)}
    end

    def get_output(state, var \\ :z), do: eval_arg(var, state)

    def get_input(%{inputs: [input | rest]} = state) do
      {input, %{state | inputs: rest}}
    end

    def inp(state, var) do
      {input, next_state} = get_input(state)
      %{next_state | var => input}
    end

    def add(state, var_a, var_b) do
      res = eval_arg(var_a, state) + eval_arg(var_b, state)
      %{state | var_a => res}
    end

    def mul(state, var_a, var_b) do
      res = eval_arg(var_a, state) * eval_arg(var_b, state)
      %{state | var_a => res}
    end

    def div(state, var_a, var_b) do
      res = div(eval_arg(var_a, state), eval_arg(var_b, state))
      %{state | var_a => res}
    end

    def mod(state, var_a, var_b) do
      a = eval_arg(var_a, state)
      b = eval_arg(var_b, state)

      if a < 0 or b <= 0, do: throw(:error)

      %{state | var_a => rem(a, b)}
    end

    def eql(state, var_a, var_b) do
      res = if eval_arg(var_a, state) == eval_arg(var_b, state), do: 1, else: 0
      %{state | var_a => res}
    end

    defp eval_arg(int, _) when is_integer(int), do: int
    defp eval_arg(var, state) when is_atom(var), do: Map.get(state, var)
  end

  import Advent2021

  @doc ~S"""
  --- Day 24: Arithmetic Logic Unit ---
  Magic smoke starts leaking from the submarine's arithmetic logic unit (ALU).
  Without the ability to perform basic arithmetic and logic functions, the
  submarine can't produce cool patterns with its Christmas lights!

  It also can't navigate. Or run the oxygen system.

  Don't worry, though - you probably have enough oxygen left to give you enough
  time to build a new ALU.

  The ALU is a four-dimensional processing unit: it has integer variables w, x,
  y, and z. These variables all start with the value 0. The ALU also supports
  six instructions:

  - inp a - Read an input value and write it to variable a.
  - add a b - Add the value of a to the value of b, then store the result in
    variable a.
  - mul a b - Multiply the value of a by the value of b, then store the result
    in variable a.
  - div a b - Divide the value of a by the value of b, truncate the result to
    an integer, then store the result in variable a. (Here, "truncate" means to
    round the value toward zero.)
  - mod a b - Divide the value of a by the value of b, then store the remainder
    in variable a. (This is also called the modulo operation.)
  - eql a b - If the value of a and b are equal, then store the value 1 in
    variable a. Otherwise, store the value 0 in variable a.


  In all of these instructions, a and b are placeholders; a will always be the
  variable where the result of the operation is stored (one of w, x, y, or z),
  while b can be either a variable or a number. Numbers can be positive or
  negative, but will always be integers.

  The ALU has no jump instructions; in an ALU program, every instruction is run
  exactly once in order from top to bottom. The program halts after the last
  instruction has finished executing.

  (Program authors should be especially cautious; attempting to execute div
  with b=0 or attempting to execute mod with a&lt;0 or b&lt;=0  will cause the
  program to crash and might even damage the ALU. These operations are never
  intended in any serious ALU program.)

  For example, here is an ALU program which takes an input number, negates it,
  and stores it in x:

  #{test_inoput(1)}

  Here is an ALU program which takes two input numbers, then sets z to 1 if the
  second input number is three times larger than the first input number, or
  sets z to 0 otherwise:

  #{test_inoput(2)}

  Here is an ALU program which takes a non-negative integer as input, converts
  it into binary, and stores the lowest (1's) bit in z, the second-lowest (2's)
  bit in y, the third-lowest (4's) bit in x, and the fourth-lowest (8's) bit in
  w:

  #{test_inoput(3)}

  Once you have built a replacement ALU, you can install it in the submarine,
  which will immediately resume what it was doing when the ALU failed:
  validating the submarine's model number. To do this, the ALU will run the
  MOdel Number Automatic Detector program (MONAD, your puzzle input).

  Submarine model numbers are always fourteen-digit numbers consisting only of
  digits 1 through 9. The digit 0 cannot appear in a model number.

  When MONAD checks a hypothetical fourteen-digit model number, it uses
  fourteen separate inp instructions, each expecting a single digit of the
  model number in order of most to least significant. (So, to check the model
  number 13579246899999, you would give 1 to the first inp instruction, 3 to
  the second inp instruction, 5 to the third inp instruction, and so on.) This
  means that when operating MONAD, each input instruction should only ever be
  given an integer value of at least 1 and at most 9.

  Then, after MONAD has finished running all of its instructions, it will
  indicate that the model number was valid by leaving a 0 in variable z.
  However, if the model number was invalid, it will leave some other non-zero
  value in z.

  MONAD imposes additional, mysterious restrictions on model numbers, and
  legend says the last copy of the MONAD documentation was eaten by a tanuki.
  You'll need to figure out what MONAD does some other way.

  To enable as many submarine features as possible, find the largest valid
  fourteen-digit model number that contains no 0 digits. What is the largest
  model number accepted by MONAD?

  """
  def_solution part_1(stream_input) do
    initial_state = parse(stream_input)

    initial_state.program
    |> Enum.chunk_every(18)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn
      {p, i}, acc when map_size(acc) == 0 ->
        IO.inspect("Step #{i + 1}")

        for i <- 1..9, into: %{} do
          {%{initial_state | program: p, program_length: length(p)} |> run_with(i), i}
        end

      {p, i}, states ->
        IO.inspect("Step #{i + 1}")

        for i <- 1..9, {out, prev_in} <- states, into: %{} do
          {%{initial_state | z: out, program: p, program_length: length(p)} |> run_with(i),
           prev_in * 10 + i}
        end
    end)
    |> Map.get(0)
  end

  @doc ~S"""
  --- Part Two ---
  As the submarine starts booting up things like the Retro Encabulator, you
  realize that maybe you don't need all these submarine features after all.

  What is the smallest model number accepted by MONAD?
  """
  def_solution part_2(stream_input) do
    initial_state = parse(stream_input)

    initial_state.program
    |> Enum.chunk_every(18)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn
      {p, i}, acc when map_size(acc) == 0 ->
        IO.inspect("Step #{i + 1}, size: #{map_size(acc)}")

        for i <- 9..1, into: %{} do
          {%{initial_state | program: p, program_length: length(p)} |> run_with(i), i}
        end

      {p, i}, states ->
        IO.inspect("Step #{i + 1}, size: #{map_size(states)}")
        IO.inspect("min max = #{inspect(Enum.min_max(Map.values(states)))}")

        for i <- 9..1, {out, prev_in} <- states do
          {i, out, prev_in * 10 + i}
        end
        |> Enum.chunk_every(5_000)
        |> Task.async_stream(
          fn chunk ->
            Enum.map(chunk, fn {i, z, s} ->
              {%{initial_state | z: z, program: p, program_length: length(p)} |> run_with(i), s}
            end)
          end,
          max_concurency: 8,
          ordered: false
        )
        |> Enum.reduce(%{}, fn {:ok, list}, acc ->
          Enum.reduce(list, acc, fn {output, state}, inner_acc ->
            Map.update(inner_acc, output, state, fn existing -> min(existing, state) end)
          end)
        end)
    end)

    # |> Map.get(0)
  end

  @doc ~S"""
  ## Example
    iex> gen_input() |> Enum.take(1)
    [[9,9,9,9,9,9,9,9,9,9,9,9,9,9]]

    iex> gen_input() |> Stream.drop(8) |> Enum.take(2)
    [[9,9,9,9,9,9,9,9,9,9,9,9,9,1], [9,9,9,9,9,9,9,9,9,9,9,9,8,9]]

    iex> gen_input(11111111111111, &Kernel.+/2) |> Enum.take(1)
    [[1,1,1,1,1,1,1,1,1,1,1,1,1,1]]

    iex> gen_input(11111111111111, &Kernel.+/2) |> Stream.drop(8) |> Enum.take(2)
    [[1,1,1,1,1,1,1,1,1,1,1,1,1,9], [1,1,1,1,1,1,1,1,1,1,1,1,2,1]]

  """
  def gen_input(n \\ 99_999_999_999_999, op \\ &Kernel.-/2) do
    Stream.resource(fn -> [n] end, &do_gen_input(&1, op), fn _ -> :ok end)
  end

  def do_gen_input([n], op) do
    digits = Integer.digits(n)

    if not Enum.member?(digits, 0) do
      {[digits], [op.(n, 1)]}
    else
      do_gen_input([op.(n, 1)], op)
    end
  end

  @doc ~S"""
  ## Example
    iex> test_input(1) |> Advent2021.stream() |> parse() |> run_with(10, :x)
    -10

    iex> test_input(2) |> Advent2021.stream() |> parse() |> run_with([1, 1])
    0

    iex> test_input(2) |> Advent2021.stream() |> parse() |> run_with([3, 9])
    1

    iex> Enum.map([:w, :x, :y, :z], fn o -> test_input(3) |> Advent2021.stream() |> parse() |> run_with(8, o) end)
    [1, 0, 0, 0]

    iex> Enum.map([:w, :x, :y, :z], fn o -> test_input(3) |> Advent2021.stream() |> parse() |> run_with(123, o) end)
    [1, 0, 1, 1]
  """
  def run_with(alu, inputs, output \\ :z) do
    alu
    |> ALU.set_input(inputs)
    |> ALU.run_program()
    |> ALU.get_output(output)
  end

  @doc ~S"""
  ## Example
  iex> parse(test_input(1) |> Advent2021.stream)
  %Day24.ALU{program: [{:inp, [:x]}, {:mul, [:x, -1]}], program_length: 2}
  """
  def parse(stream) do
    Enum.map(stream, fn line ->
      [instruction | rest] = String.split(line, " ", trim: true)
      args = Enum.map(rest, &parse_arg/1)
      {String.to_atom(instruction), args}
    end)
    |> then(fn program -> struct(ALU, program: program, program_length: length(program)) end)
  end

  def parse_arg(arg) do
    String.to_integer(arg)
  rescue
    ArgumentError -> String.to_atom(arg)
  end

  def test_input(1) do
    """
    inp x
    mul x -1
    """
  end

  def test_input(2) do
    """
    inp z
    inp x
    mul z 3
    eql z x
    """
  end

  def test_input(3) do
    """
    inp w
    add z w
    mod z 2
    div w 2
    add y w
    mod y 2
    div w 2
    add x w
    mod x 2
    div w 2
    mod w 2
    """
  end
end
