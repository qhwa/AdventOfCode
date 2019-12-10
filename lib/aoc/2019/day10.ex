defmodule AOC.Y2019.Day10 do
  @moduledoc """
  @see http://adventofcode.com/2019/day/10
  """

  def p1 do
    pts =
      "priv/data/2019/day10.txt"
      |> File.read!()
      |> parse()

    pts
    |> Stream.map(&{&1, count(&1, pts)})
    |> Enum.max_by(fn {_, c} -> c end)
  end

  def p2 do
    :ok
  end

  def example do
    input = """
    .#..#..###
    ####.###.#
    ....###.#.
    ..###.##.#
    ##.##.#.#.
    ....###..#
    ..#.#..#.#
    #..#.#.###
    .##...##.#
    .....#.#..
    """

    pts = parse(input)

    pts
    |> Stream.map(&{&1, count(&1, pts)})
    |> Enum.max_by(fn {_, c} -> c end)
  end

  defp parse(input) do
    input
    |> String.split("\n")
    |> Stream.with_index()
    |> Stream.flat_map(&parse_line(&1))
    |> Enum.to_list()
  end

  defp parse_line({line, y}) do
    line
    |> String.to_charlist()
    |> Stream.with_index()
    |> Enum.reduce([], fn
      {?., _}, acc -> acc
      {?#, x}, acc -> [{x, y} | acc]
    end)
  end

  defp count(c, pts) do
    Enum.group_by(pts, &angle(&1, c))
    |> Map.keys()
    |> length()
  end

  # defp angle(c, c), do: nil
  defp angle({cx, cy}, {x, y}), do: :math.atan2(y - cy, x - cx)
end
