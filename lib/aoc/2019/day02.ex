defmodule AOC.Y2019.Day02 do
  @moduledoc """
  @see https://adventofcode.com/2019/day/2
  """

  @program "priv/data/2019/day02.txt"
           |> File.read!()
           |> String.trim()
           |> String.split(",")
           |> Enum.map(&String.to_integer/1)

  def part1 do
    @program
    |> List.replace_at(1, 12)
    |> List.replace_at(2, 2)
    |> run()
  end

  def part2() do
    {n, v} =
      for noun <- 0..99, verb <- 0..99 do
        {noun, verb}
      end
      |> Enum.find(fn {n, v} ->
        [head, _, _ | tail] = @program
        19_690_720 == run([head, n, v | tail])
      end)

    n * 100 + v
  end

  def run(program, cursor \\ 0)

  def run(program, cursor) when cursor >= length(program) do
    program
  end

  def run(program, cursor) do
    result =
      program
      |> Enum.slice(cursor, 4)
      |> operate(program)

    case result do
      :halt ->
        hd(program)

      _ ->
        run(result, cursor + 4)
    end
  end

  def operate([99 | _tail], _), do: :halt

  def operate([1, r1, r2, w], program) do
    ret = Enum.at(program, r1) + Enum.at(program, r2)
    List.replace_at(program, w, ret)
  end

  def operate([2, r1, r2, w], program) do
    ret = Enum.at(program, r1) * Enum.at(program, r2)
    List.replace_at(program, w, ret)
  end
end
