defmodule AOC.Y2019.Day08 do
  @moduledoc """
  @see https://adventofcode.com/2019/day/8
  """

  @behaviour AOC

  def setup, do: {:ok, parse()}

  def p1(input), do: input |> least_zero_layer() |> digest()
  def p2(input), do: input |> compose_layers() |> print()

  defp least_zero_layer(layers), do: Enum.min_by(layers, &count(&1, 0))

  defp digest(layer), do: count(layer, 1) * count(layer, 2)

  defp count(enum, value), do: Enum.count(enum, &(&1 == value))

  defp compose_layers(layers) do
    for i <- 0..149, do: pixel(layers, i)
  end

  defp pixel([top | tail], i) do
    case Enum.at(top, i) do
      2 ->
        pixel(tail, i)

      p ->
        p
    end
  end

  defp print(layer) do
    layer
    |> Enum.map(fn
      0 -> ' '
      1 -> ?*
    end)
    |> Enum.chunk_every(25)
    |> Enum.intersperse(?\n)
    |> IO.puts()
  end

  defp parse() do
    File.read!("priv/data/2019/day08.txt")
    |> String.trim()
    |> String.to_charlist()
    |> Stream.map(&(&1 - ?0))
    |> Enum.chunk_every(25 * 6)
  end
end
