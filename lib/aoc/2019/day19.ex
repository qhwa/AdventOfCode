defmodule AOC.Y2019.Day19 do
  @moduledoc """
  @see https://adventofcode.com/2019/day/19
  """

  @program Intcode.load_file("priv/data/2019/day19.txt")
  @ship_size 100

  def p1 do
    for x <- 0..49, y <- 0..49, point_covered?(x, y) do
      {x, y}
    end
    |> Enum.count()
  end

  def p2 do
    bottom = bin_search_bottom_left_y(0, 1000)
    left = first_covered_at_row(bottom)

    # Top right
    [{0, -1}, {0, 0}, {1, 0}]
    |> Enum.each(fn {x, y} ->
        {x, y, point_covered?(left + @ship_size + x - 1, bottom - @ship_size + y + 1)},
        label: :top_right
      )
    end)

    # Bottom left
    [{-1, 0}, {0, 0}, {0, 1}]
    |> Enum.each(fn {x, y} ->
        {x, y, point_covered?(left + x, bottom + y)},
        label: :bottom_left
      )
    end)

    {left, bottom - @ship_size + 1}
  end

  defp bin_search_bottom_left_y(min, max) when min > max, do: min - 1

  defp bin_search_bottom_left_y(min, max) do
    half = div(min + max, 2)

    bottom_left_x = first_covered_at_row(half)


    case next_move(bottom_left_x + @ship_size - 1, half - @ship_size + 1) do
      :found ->
        half

      :up ->
        bin_search_bottom_left_y(min, half)

      :down ->
        bin_search_bottom_left_y(half, max)
    end
  end

  defp next_move(x, y) do
    cond do
      point_covered?(x, y - 1) ->
        :up

      !point_covered?(x, y) ->
        :down

      true ->
        :found
    end
  end

  defp point_covered?(x, y) do
    [1] == Intcode.Computer.function_mode(@program, input: [x, y])
  end

  defp first_covered_at_row(y) do
    (y * 2)..100_000 |> Enum.find(&point_covered?(&1, y))
  end
end
