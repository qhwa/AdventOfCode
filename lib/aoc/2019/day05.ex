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

  def p1 do
    run_program(@program, 0, 1)
  end

  def p2 do
    run_program(@program, 0, 5)
  end

  def example do
    run_program(to_map([3, 9, 8, 9, 10, 9, 4, 9, 99, -1, 8]), 0, 9)
  end

  def run_program(program, p, input, output \\ []) do
    case program[p] do
      99 ->
        output |> Enum.reverse()

      3 ->
        run_program(
          %{program | program[p + 1] => input},
          p + 2,
          input,
          output
        )

      op when rem(op, 10) == 4 ->
        run_program(
          program,
          p + 2,
          input,
          [read(program, mode(op), p + 1) | output]
        )

      op when rem(op, 10) == 5 ->
        run_program(
          program,
          goto(program, p, op, &(&1 != 0)),
          input,
          output
        )

      op when rem(op, 10) == 6 ->
        run_program(
          program,
          goto(program, p, op, &(&1 == 0)),
          input,
          output
        )

      op when rem(op, 10) == 7 ->
        program
        |> compare(p, op, &(&1 < &2))
        |> run_program(p + 4, input, output)

      op when rem(op, 10) == 8 ->
        program
        |> compare(p, op, &(&1 == &2))
        |> run_program(p + 4, input, output)

      op when rem(op, 10) in 1..2 ->
        op
        |> calc(program, p)
        |> run_program(p + 4, input, output)
    end
  end

  defp mode(op, pos \\ 0) do
    op
    |> rem(floor(:math.pow(10, pos + 3)))
    |> div(floor(:math.pow(10, pos + 2)))
  end

  defp read(program, 0, p), do: program[program[p]]
  defp read(program, 1, p), do: program[p]

  defp goto(program, p, op, if_jump) do
    value = read(program, mode(op), p + 1)

    if if_jump.(value) do
      read(program, mode(op, 1), p + 2)
    else
      p + 3
    end
  end

  defp compare(program, p, op, fun) do
    r1 = read(program, mode(op), p + 1)
    r2 = read(program, mode(op, 1), p + 2)
    wp = program[p + 3]

    ret = if fun.(r1, r2), do: 1, else: 0
    %{program | wp => ret}
  end

  defp calc(op, program, p) do
    {p1, p2, p3} = {p + 1, p + 2, p + 3}

    r1 = read(program, mode(op), p1)
    r2 = read(program, mode(op, 1), p2)
    wp = program[p3]

    %{program | wp => execute(rem(op, 100), r1, r2)}
  end

  defp execute(1, a, b), do: a + b
  defp execute(2, a, b), do: a * b
end
