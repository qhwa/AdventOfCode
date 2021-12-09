defmodule Y2021.Day09 do
  @moduledoc """
  https://adventofcode.com/2021/day/9

  Run with: `mix run lib/aoc/2021/day09.exs`
  """
  def p1 do
    parse_map()
    |> low_points()
    |> Stream.map(fn {_pos, level} -> level + 1 end)
    |> Enum.sum()
  end

  def p2 do
    map = parse_map()

    map
    |> low_points()
    |> Stream.map(&to_basin(&1, map))
    |> Stream.map(&length/1)
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.reduce(&Kernel.*/2)
  end

  defp parse_map do
    AOC.Input.stream("2021/day09.txt")
    |> Stream.map(fn line ->
      line
      |> String.split("", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
    |> Enum.to_list()
    |> List.to_tuple()
  end

  defp low_points(map) do
    {w, h} = size(map)

    for x <- 0..(w - 1),
        y <- 0..(h - 1),
        low?(map, {x, y}) do
      {{x, y}, level_at(map, {x, y})}
    end
  end

  defp level_at(map, {x, y}) do
    map
    |> elem(y)
    |> elem(x)
  end

  defp low?(map, {x, y}) do
    center_h = level_at(map, {x, y})

    neighbours({x, y}, map)
    |> Enum.all?(&(level_at(map, &1) > center_h))
  end

  defp neighbours({x, y}, map) do
    {w, h} = size(map)

    [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
    |> Enum.filter(fn {x, y} ->
      x >= 0 and y >= 0 and x < w and y < h
    end)
  end

  defp size(map) do
    {map |> elem(0) |> tuple_size(), tuple_size(map)}
  end

  def to_basin({{x, y}, _level}, map) do
    {[], connected, _visited} =
      Stream.iterate({[{x, y}], [], []}, fn {targets, connected, visited} ->
        new_neighbours =
          targets
          |> Enum.flat_map(&neighbours(&1, map))
          |> Enum.uniq()
          |> Kernel.--(visited)

        in_basin =
          new_neighbours
          |> Enum.reject(&(level_at(map, &1) == 9))

        {
          in_basin,
          in_basin ++ connected,
          new_neighbours ++ visited
        }
      end)
      |> Stream.drop_while(fn {visible, _, _} -> visible != [] end)
      |> Stream.take(1)
      |> Enum.to_list()
      |> hd()

    connected
  end
end

Y2021.Day09.p1() |> IO.inspect(label: "part 1")
Y2021.Day09.p2() |> IO.inspect(label: "part 2")
