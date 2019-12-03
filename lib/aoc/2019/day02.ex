defmodule AOC.Y2019.Day02 do
  @moduledoc """
  @see https://adventofcode.com/2019/day/2
  """

  @program "priv/data/2019/day02.txt"
           |> File.read!()
           |> String.trim()
           |> String.split(",")
           |> Stream.map(&String.to_integer/1)
           |> Enum.reduce({0, %{}}, fn x, {i, map} -> {i + 1, Map.put(map, i, x)} end)
           |> elem(1)

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

    r1 = Map.get(program, Map.get(program, p1))
    r2 = Map.get(program, Map.get(program, p2))
    w = Map.get(program, p3)

    Map.put(program, w, execute(op, r1, r2))
  end

  defp execute(1, a, b), do: a + b
  defp execute(2, a, b), do: a * b

  defp to_map(list) do
    list
    |> Enum.reduce({0, %{}}, fn x, {i, map} -> {i + 1, Map.put(map, i, x)} end)
    |> elem(1)
  end
end
