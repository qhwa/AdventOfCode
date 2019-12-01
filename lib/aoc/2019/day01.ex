defmodule AOC.Y2019.Day01 do
  @moduledoc """
  @see https://adventofcode.com/2019/day/1
  """

  @masses "priv/data/2019/day01.txt"
          |> File.stream!()
          |> Stream.map(fn line ->
            line
            |> String.trim_trailing()
            |> String.to_integer()
          end)
          |> Enum.to_list()

  def part1 do
    @masses
    |> Enum.reduce(0, &(div(&1, 3) - 2 + &2))
  end

  def part2 do
    @masses
    |> Enum.reduce(0, &(fuel(&1) + &2))
  end

  def fuel(mass) do
    case div(mass, 3) - 2 do
      x when x > 0 ->
        x + fuel(x)

      x when x <= 0 ->
        0
    end
  end
end
