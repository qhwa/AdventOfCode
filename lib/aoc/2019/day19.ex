defmodule AOC.Y2019.Day19 do
  @moduledoc """
  @see https://adventofcode.com/2019/day/19
  """

  @program Intcode.load_file("priv/data/2019/day19.txt")
  @ship_size 100

  def p1 do
    for x <- 0..49, y <- 0..49, in_beam?(x, y) do
      {x, y}
    end
    |> Enum.count()
  end

  def p2 do
    y1 = bin_search_bottom_left_y(0, 1000)
    x0 = first_covered_at_row(y1)

    {x0, y1 - @ship_size + 1}
  end

  defp bin_search_bottom_left_y(min, max) when min > max, do: min - 1

  defp bin_search_bottom_left_y(min, max) do
    y = div(min + max, 2)
    x = first_covered_at_row(y)

    if valid?(x, y) do
      bin_search_bottom_left_y(min, y - 1)
    else
      bin_search_bottom_left_y(y + 1, max)
    end
  end

  defp valid?(x0, y1) do
    x1 = x0 + @ship_size - 1
    y0 = y1 - @ship_size + 1
    in_beam?(x0, y0) && in_beam?(x1, y0) && in_beam?(x1, y1)
  end

  defp in_beam?(x, y) do
    [1] == Intcode.Computer.function_mode(@program, input: [x, y])
  end

  defp first_covered_at_row(y) do
    (y * 2)..100_000 |> Enum.find(&in_beam?(&1, y))
  end
end
