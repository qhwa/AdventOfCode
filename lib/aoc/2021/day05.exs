defmodule Y2021.Day05 do
  @moduledoc """
  https://adventofcode.com/2021/day/5

  Run with: `mix run lib/aoc/2021/day05.exs`
  """
  def p1 do
    AOC.Input.stream("2021/day05.txt", &parse_seg/1)
    |> Stream.filter(fn [x1, y1, x2, y2] -> x1 == x2 || y1 == y2 end)
    |> count_overlap()
  end

  def p2 do
    AOC.Input.stream("2021/day05.txt", &parse_seg/1)
    |> count_overlap()
  end

  defp parse_seg(line) do
    Regex.run(~r/(\d+),(\d+) -> (\d+),(\d+)/, line, capture: :all_but_first)
    |> Enum.map(&String.to_integer/1)
  end

  defp count_overlap(segs) do
    segs
    |> Stream.flat_map(fn [x1, y1, x2, y2] ->
      max_step = max(abs(x2 - x1), abs(y2 - y1))
      dx = div(x2 - x1, max_step)
      dy = div(y2 - y1, max_step)

      Stream.iterate({x1, y1}, fn {x, y} -> {x + dx, y + dy} end)
      |> Stream.take(max_step + 1)
      |> Enum.to_list()
    end)
    |> Enum.frequencies()
    |> Enum.count(fn {_, count} -> count > 1 end)
  end
end

Y2021.Day05.p1() |> IO.inspect(label: "part 1")
Y2021.Day05.p2() |> IO.inspect(label: "part 2")
