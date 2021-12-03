defmodule Y2021.Day02 do
  @moduledoc """
  https://adventofcode.com/2021/day/2

  Run with: `mix run lib/aoc/2021/day02.exs`
  """

  def part1 do
    {x, y} =
      AOC.Input.stream("2021/day02.txt", &to_instruction/1)
      |> Enum.reduce({0, 0}, fn {dx, dy}, {x, y} ->
        {x + dx, y + dy}
      end)

    x * y
  end

  def part2 do
    {x, y, _aim} =
      AOC.Input.stream("2021/day02.txt", &to_instruction/1)
      |> Enum.reduce({0, 0, 0}, fn
        {0, daim}, {x, y, aim} ->
          {x, y, aim + daim}

        {forward, 0}, {x, y, aim} ->
          {x + forward, y + aim * forward, aim}
      end)

    x * y
  end

  defp to_instruction("forward " <> value),
    do: {parse_value(value), 0}

  defp to_instruction("down " <> value),
    do: {0, parse_value(value)}

  defp to_instruction("up " <> value),
    do: {0, -parse_value(value)}

  defp parse_value(v_str) do
    {value, _} = Integer.parse(v_str)
    value
  end
end

Y2021.Day02.part1() |> IO.inspect(label: "part 1")
Y2021.Day02.part2() |> IO.inspect(label: "part 2")
