defmodule AOC.Y2019.Day19 do
  @moduledoc """
  @see https://adventofcode.com/2019/day/19
  """

  @program Intcode.load_file("priv/data/2019/day19.txt")

  def p1 do
    for x <- 0..49, y <- 0..49, fit_in?({x, y}) do
      {x, y}
    end
    |> Enum.count()
  end

  def p2 do
    bin_search_angle(40, 60)
  end

  defp bin_search_angle(min, max) when min > max, do: min - 1

  defp bin_search_angle(min, max) do
    half = div(min + max, 2)

    if fit_in?({50, half}) do
      bin_search_angle(min, half - 1)
    else
      bin_search_angle(half + 1, max)
    end
  end

  defp fit_in?({x, y}) do
    [1] == Intcode.Computer.function_mode(@program, input: [x, y])
  end
end
