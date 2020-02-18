defmodule AOC.Y2019.Day01 do
  @moduledoc """
  @see https://adventofcode.com/2019/day/1
  """

  def part1 do
    read_input()
    |> Stream.map(&(div(&1, 3) - 2))
    |> Enum.sum()
  end

  def part2 do
    read_input()
    |> Stream.map(&fuel/1)
    |> Enum.sum()
  end

  defp read_input,
    do: AOC.Input.stream("2019/day01.txt", &String.to_integer/1)

  defp fuel(mass) do
    case div(mass, 3) - 2 do
      x when is_integer(x) and x > 0 ->
        x + fuel(x)

      _ ->
        0
    end
  end
end
