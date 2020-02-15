defmodule AOC.Y2015.Day24 do
  @moduledoc """
  @see https://adventofcode.com/2015/day/24
  """
  def p1 do
    numbers = read_input()
    sum = Enum.sum(numbers)

    groups(numbers, div(sum, 3))
    |> Enum.sort_by(&{length(&1), qe(&1)})
    |> hd()
    |> qe()
  end

  defp groups(_, n) when n < 0 do
    :invalid
  end

  defp groups([], 0) do
    [[]]
  end

  defp groups([], _) do
    :invalid
  end

  defp groups(_, 0) do
    :invalid
  end

  defp groups([h | tail], n) do
    without_h =
      case groups(tail, n) do
        :invalid -> []
        o -> o
      end

    with_h =
      case groups(tail, n - h) do
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
