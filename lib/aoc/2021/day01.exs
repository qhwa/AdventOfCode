defmodule Y2021.Day01 do
  @moduledoc """
  https://adventofcode.com/2021/day/1

  Run with: `mix run lib/aoc/2021/day01.exs`
  """

  def part1 do
    AOC.Input.stream("2021/day01.txt", &String.to_integer/1)
    |> count_increased()
  end

  def part2 do
    AOC.Input.stream("2021/day01.txt", &String.to_integer/1)
    |> to_chunked_sums()
    |> count_increased()
  end

  defp count_increased(stream) do
    stream
    |> Stream.chunk_every(2, 1, :discard)
    |> Enum.count(fn [a, b] -> b > a end)
  end

  defp to_chunked_sums(stream) do
    stream
    |> Stream.chunk_every(3, 1, :discard)
    |> Stream.map(&Enum.sum/1)
  end
end

Y2021.Day01.part1() |> IO.inspect(label: "part 1")
Y2021.Day01.part2() |> IO.inspect(label: "part 2")
