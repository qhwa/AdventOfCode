defmodule AOC.Y2019.Day10 do
  @moduledoc """
  @see http://adventofcode.com/2019/day/10
  """

  def p1 do
    pts = read_input()

    pts
    |> Stream.map(&number_of_asteroids_in_sight(&1, pts))
    |> Enum.max()
  end

  def p2 do
    pts = read_input()

    origin = Enum.max_by(pts, &number_of_asteroids_in_sight(&1, pts))

    {{x, y}, _, _} =
      pts
      |> Stream.reject(&(&1 == origin))

      # data structure:
      # {point, distance_to_origin, degree_to_origin}
      |> Stream.map(fn {x, y} ->
        {
          {x, y},
          distance2({x, y}, origin),
          angle({x, y}, origin)
        }
      end)

      # We only have to do sorting exactly once
      # as items inside tupples will effect sorting.
      # That's the new thing I learned today.
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

  defp number_of_asteroids_in_sight(origin, pts) do
    pts
    |> Enum.group_by(&angle(&1, origin))
    |> Enum.count()
  end

  defp angle({x, y}, {cx, cy}) do
    # notice that we rotate it by -90 deg,
    # because we count 0 from upside
    deg = :math.atan2(x - cx, cy - y) * 180 / :math.pi()
    if deg < 0, do: 360 + deg, else: deg
  end

  defp distance2({x, y}, {cx, cy}) do
    # If only used for comparing,
    # no need to use `:math.pow` here
    # this is good enough
    abs(cx - x) + abs(cy - y)
  end
end
