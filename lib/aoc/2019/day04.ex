defmodule AOC.Y2019.Day04 do
  @moduledoc """
  @see https://adventofcode.com/2019/day/4
  """

  @input 147_981..691_423

  def part1 do
    @input
    |> Stream.map(&Integer.digits/1)
    |> Stream.filter(&valid_in_part1?/1)
    |> Enum.count()
  end

  def part2 do
    @input
    |> Stream.map(&Integer.digits/1)
    |> Stream.filter(&valid_in_part2?/1)
    |> Enum.count()
  end

  defp valid_in_part1?(digits) do
    never_decrease?(digits) && repeated?(digits)
  end

  defp valid_in_part2?(digits) do
    never_decrease?(digits) && valid_repeating_parts(digits) != []
  end

  defp never_decrease?([]), do: true
  defp never_decrease?([head | tail]), do: never_decrease?(tail, head)

  defp never_decrease?([], _), do: true
  defp never_decrease?([head | _], prev) when head < prev, do: false
  defp never_decrease?([head | tail], _), do: never_decrease?(tail, head)

  defp repeated?([head | tail]), do: repeated?(tail, head)
  defp repeated?([], _), do: false
  defp repeated?([head | _], head), do: true
  defp repeated?([head | tail], _), do: repeated?(tail, head)

  defp valid_repeating_parts([head | tail]) do
    valid_repeating_parts(tail, [{head, 1}])
  end

  defp valid_repeating_parts([], acc) do
    Enum.filter(acc, fn {_, n} -> n == 2 end)
  end

  defp valid_repeating_parts([head | tail], [{head, n} | acc_tail]) do
    valid_repeating_parts(tail, [{head, n + 1} | acc_tail])
  end

  defp valid_repeating_parts([head | tail], acc) do
    valid_repeating_parts(tail, [{head, 1} | acc])
  end
end
