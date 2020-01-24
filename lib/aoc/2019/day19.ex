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
    {x0, y1} = search(0, @ship_size)
    x0 * 10_000 + y1 - @ship_size + 1
  end

  defp search(x, y) do
    cond do
      not in_beam?(x, y) ->
        search(x + 1, y)

      valid?(x, y) ->
        {x, y}

      true ->
        # linear search works:
        search(x, y + 1)
    end
  end

  defp valid?(x0, y1) do
    x1 = x0 + @ship_size - 1
    y0 = y1 - @ship_size + 1
    in_beam?(x0, y0) && in_beam?(x1, y0) && in_beam?(x1, y1)
  end

  defp in_beam?(x, y),
    do: [1] == Intcode.Computer.function_mode(@program, input: [x, y])
end
