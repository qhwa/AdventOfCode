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
    never_decrease?(digits) && has_valid_parts?(digits)
  end

  defp never_decrease?([_]), do: true
  defp never_decrease?([a, b | _tail]) when a > b, do: false
  defp never_decrease?([_, b | tail]), do: never_decrease?([b | tail])

  defp repeated?([_]), do: false
  defp repeated?([a, a | _]), do: true
  defp repeated?([_, a | tail]), do: repeated?([a | tail])

  defp has_valid_parts?(list) do
    parts =
      list
      |> Enum.chunk_by(& &1)
      |> Enum.map(&length/1)

    2 in parts
  end
end
