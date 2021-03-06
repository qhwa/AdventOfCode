defmodule AOC.Y2015.Day20 do
  @moduledoc """
  @see https://adventofcode.com/2015/day/20
  """

  def puzzle do
    1
    |> find(29_000_000 / 10, fn _, _ -> true end)
    |> IO.puts()
  end

  def puzzle2 do
    1
    |> find(29_000_000 / 11, &(div(&2, &1) <= 50))
    |> IO.puts()
  end

  def find(n, target, max) do
    if sum_of_factors(n, max) >= target do
      n
    else
      find(n + 1, target, max)
    end
  end

  def sum_of_factors(n, max) do
    e = n |> :math.sqrt() |> trunc()

    1..e
    |> Enum.flat_map(fn
      x when rem(n, x) != 0 ->
        []

      x when x != div(n, x) ->
        [x, div(n, x)]

      x ->
        [x]
    end)
    |> Enum.filter(fn x -> max.(x, n) end)
    |> Enum.sum()
  end
end
