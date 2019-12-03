defmodule AOC.Y2019.Day02 do
  @moduledoc """
  @see https://adventofcode.com/2019/day/2
  """

  import Helper.MyList, only: [to_map: 1]

  @program "priv/data/2019/day02.txt"
           |> File.read!()
           |> String.trim()
           |> String.split(",")
           |> Stream.map(&String.to_integer/1)
           |> to_map()

  def part1 do
    run_program(@program, 12, 2)
  end

  def part2 do
    for n <- 0..99, v <- 0..99 do
      {n, v}
    end
    |> Enum.find(fn {n, v} ->
      run_program(@program, n, v) == 19_690_720
    end)
  end

  def run_program(p) when is_list(p) do
    p
    |> to_map()
    |> run(0)
  end

  def run_program(p, n, v) do
    %{p | 1 => n, 2 => v}
    |> run(0)
  end

  def run(program, p) do
    case Map.get(program, p) do
      99 ->
        Map.get(program, 0)

      op when op in 1..2 ->
        op
        |> calc(program, p)
        |> run(p + 4)
    end
  end

  defp calc(op, program, p) do
    {p1, p2, p3} = {p + 1, p + 2, p + 3}

    r1 = program[program[p1]]
    r2 = program[program[p2]]
    wp = program[p3]

    %{program | wp => execute(op, r1, r2)}
  end

  defp execute(1, a, b), do: a + b
  defp execute(2, a, b), do: a * b
end
