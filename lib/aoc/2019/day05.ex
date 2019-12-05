defmodule AOC.Y2019.Day05 do
  @moduledoc """
  @see https://adventofcode.com/2019/day/5
  """

  import Helper.MyList, only: [to_map: 1]

  @program "priv/data/2019/day05.txt"
           |> File.read!()
           |> String.trim()
           |> String.split(",")
           |> Stream.map(&String.to_integer/1)
           |> to_map()

  @valid_ops [
    1,
    2,
    101,
    102,
    104,
    1001,
    1002,
    1101,
    1102
  ]

  def p1 do
    run_program(@program, 0, 1)
  end

  def part2 do
  end

  def example do
    run_program(to_map([3, 0, 4, 0, 99]), 0, 1)
  end

  def run_program(program, p, input, output \\ []) do
    case program[p] do
      99 ->
        {:halt, output |> Enum.reverse()}

      3 ->
        run_program(
          %{program | program[p + 1] => input},
          p + 2,
          input,
          output
        )

      4 ->
        run_program(
          program,
          p + 2,
          input,
          [program[program[p + 1]] | output]
        )

      104 ->
        run_program(
          program,
          p + 2,
          input,
          [program[p + 1] | output]
        )

      op when op in @valid_ops ->
        op
        |> calc(program, p)
        |> run_program(p + 4, input, output)
    end
  end

  defp calc(op, program, p) do
    {p1, p2, p3} = {p + 1, p + 2, p + 3}

    r1 = if div(rem(op, 1000), 100) == 1, do: program[p1], else: program[program[p1]]
    r2 = if div(rem(op, 10000), 1000) == 1, do: program[p2], else: program[program[p2]]
    wp = program[p3]

    %{program | wp => execute(rem(op, 100), r1, r2)}
  end

  defp execute(1, a, b), do: a + b
  defp execute(2, a, b), do: a * b
end
