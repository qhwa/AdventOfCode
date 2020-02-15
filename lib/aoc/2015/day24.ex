defmodule AOC.Y2015.Day24 do
  @moduledoc """
  @see https://adventofcode.com/2015/day/24
  """
  def p1 do
    result(3)
  end

  def p2 do
    result(4)
  end

  defp result(parts) do
    numbers = read_input()
    sum = Enum.sum(numbers) |> div(parts)

    numbers
    |> groups_by_sum(sum)
    |> Enum.sort_by(&{length(&1), qe(&1)})
    |> hd()
    |> qe()
  end

  defp groups_by_sum(_, n) when n < 0 do
    :invalid
  end

  defp groups_by_sum([], 0) do
    [[]]
  end

  defp groups_by_sum([], _) do
    :invalid
  end

  defp groups_by_sum(_, 0) do
    :invalid
  end

  defp groups_by_sum([h | tail], n) do
    without_h =
      case groups_by_sum(tail, n) do
        :invalid -> []
        o -> o
      end

    with_h =
      case groups_by_sum(tail, n - h) do
        :invalid -> []
        o -> o
      end

    for(g <- with_h, do: [h | g]) ++ without_h
  end

  defp qe(numbers) do
    Enum.reduce(numbers, &Kernel.*/2)
  end

  defp read_input do
    AOC.Input.stream("2015/day24.txt", &String.to_integer/1)
    |> Enum.to_list()
  end
end
