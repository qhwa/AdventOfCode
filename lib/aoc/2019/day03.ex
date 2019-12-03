defmodule AOC.Y2019.Day03 do
  @moduledoc """
  @see https://adventofcode.com/2019/day/3
  """

  @line_commands "2019/day03.txt"
                 |> AOC.Input.stream()
                 |> Enum.to_list()

  def part1 do
    [line_a, line_b] = @line_commands |> Enum.map(&parse_line/1)

    {x, y} = closest_intersection(line_a, line_b)
    abs(x) + abs(y)
  end

  def part2 do
  end

  def example() do
    line_a = parse_line("R75,D30,R83,U83,L12,D49,R71,U7,L72")
    line_b = parse_line("U62,R66,U55,R34,D71,R55,D58,R83")

    {x, y} = closest_intersection(line_a, line_b)
    abs(x) + abs(y)
  end

  defp parse_line(data) do
    {segments, _} =
      data
      |> String.split(",")
      |> Stream.map(fn <<dir::binary-size(1), n::binary>> ->
        {String.to_atom(dir), String.to_integer(n)}
      end)
      |> Enum.reduce({[], {0, 0}}, fn {dir, len}, {lines, {x, y}} ->
        move(dir, {x, y}, len, lines)
      end)

    segments
  end

  defp move(:R, {x, y}, len, lines) do
    new_line = {{x, y}, {x + len, y}}
    {[new_line | lines], {x + len, y}}
  end

  defp move(:L, {x, y}, len, lines) do
    new_line = {{x, y}, {x - len, y}}
    {[new_line | lines], {x - len, y}}
  end

  defp move(:U, {x, y}, len, lines) do
    new_line = {{x, y}, {x, y - len}}
    {[new_line | lines], {x, y - len}}
  end

  defp move(:D, {x, y}, len, lines) do
    new_line = {{x, y}, {x, y + len}}
    {[new_line | lines], {x, y + len}}
  end

  def closest_intersection(line_a, line_b) do
    for seg_a <- line_a,
        seg_b <- line_b,
        point <- inter(seg_a, seg_b),
        point != {0, 0} do
      point
    end
    |> Enum.min_by(fn {x, y} -> abs(x) + abs(y) end)
  end

  defp inter({{xa, ya0}, {xa, ya1}}, {{xb0, yb}, {xb1, yb}})
       when xa in xb0..xb1 and yb in ya0..ya1 do
    [{xa, yb}]
  end

  defp inter({{xa0, ya}, {xa1, ya}}, {{xb, yb0}, {xb, yb1}})
       when ya in yb0..yb1 and xb in xa0..xa1 do
    [{xb, ya}]
  end

  defp inter(_, _), do: []
end
