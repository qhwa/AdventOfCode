defmodule AOC.Y2019.Day10 do
  @moduledoc """
  @see http://adventofcode.com/2019/day/10
  """

  def p1 do
    pts = read_input()

    pts
    |> Stream.map(&asteroid_detect_count(&1, pts))
    |> Enum.max()
  end

  def p2 do
    pts = read_input()

    origin = Enum.max_by(pts, &asteroid_detect_count(&1, pts))

    {{x, y}, _, _} =
      pts
      |> Stream.reject(&(&1 == origin))

      # data structure:
      # {point, distance_from_origin, degree_to_origin}
      |> Stream.map(fn {x, y} ->
        {
          {x, y},
          distance2({x, y}, origin),
          angle({x, y}, origin)
        }
      end)
      |> Enum.sort_by(fn {_, d, r} -> {r, d} end)
      |> Enum.chunk_by(fn {_, _, r} -> r end)

      # Here's the tricky part:
      # the length of the list above is more than 200
      |> Enum.at(199)
      |> hd()

    x * 100 + y
  end

  defp read_input do
    "2019/day10.txt"
    |> AOC.Input.stream()
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

  defp distance2({x, y}, {cx, cy}) do
    abs(cx - x) + abs(cy - y)
  end

  defp angle({x, y}, {cx, cy}) do
    deg = :math.atan2(x - cx, cy - y) * 180 / :math.pi()
    if deg < 0, do: 360 + deg, else: deg
  end

  defp asteroid_detect_count(c, pts) do
    Enum.group_by(pts, &angle(&1, c)) |> Enum.count()
  end
end
