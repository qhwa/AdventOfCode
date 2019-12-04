defmodule AOC.Y2019.Day03 do
  @moduledoc """
  @see https://adventofcode.com/2019/day/3
  """

  def part1 do
    parse_input()
    |> all_intersection()
    |> Stream.map(&manhanttan_distance/1)
    |> Enum.min()
  end

  def part2 do
    [line_a, line_b] = parse_input()

    [line_a, line_b]
    |> all_intersection()
    |> Stream.map(&(step_count(line_a, &1) + step_count(line_b, &1)))
    |> Enum.min()
  end

  defp parse_wire(data) do
    {lines, _} =
      data
      |> String.split(",")
      |> Stream.map(fn <<dir, n::binary>> ->
        {dir, String.to_integer(n)}
      end)
      |> Enum.reduce({[], {0, 0}}, fn {dir, step}, {lines, {x, y}} ->
        {seg, pt} = move(dir, {x, y}, step)
        {[seg | lines], pt}
      end)

    Enum.reverse(lines)
  end

  defp move(dir, {x, y}, step) do
    endpt =
      case dir do
        ?R -> {x + step, y}
        ?L -> {x - step, y}
        ?U -> {x, y - step}
        ?D -> {x, y + step}
      end

    {
      {{x, y}, endpt},
      endpt
    }
  end

  def all_intersection([line_a, line_b]) do
    for seg_a <- line_a,
        seg_b <- line_b,
        point <- inter(seg_a, seg_b),
        point != {0, 0} do
      point
    end
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

  def manhanttan_distance({x, y}) do
    abs(x) + abs(y)
  end

  def step_count(line, p) do
    line
    |> Enum.reduce_while(0, fn seg, acc ->
      case distance(seg, p) do
        nil ->
          {:cont, acc + len(seg)}

        n ->
          {:halt, acc + n}
      end
    end)
  end

  def len({{x0, y0}, {x1, y1}}) do
    abs(x0 - x1) + abs(y1 - y0)
  end

  def distance({{x, y0}, {x, y1}}, {x, y}) when y in y0..y1 do
    abs(y - y0)
  end

  def distance({{x0, y}, {x1, y}}, {x, y}) when x in x0..x1 do
    abs(x - x0)
  end

  def distance(_, _) do
    nil
  end

  defp parse_input do
    AOC.Input.stream("2019/day03.txt")
    |> Enum.map(&parse_wire/1)
  end
end
