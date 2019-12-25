defmodule AOC.Y2019.Day18 do
  @moduledoc """
  @see https://adventofcode.com/2019/day/18
  """

  @map GameMap.load_file("priv/data/2019/day18.txt")

  def p1 do
    shortest_path(@map)
  end

  def p2 do
  end

  def shortest_path(map) do
    pos = GameMap.locate(map, ?@)
    shortest_path(map, pos)
  end

  defp shortest_path(map, pos) do
    walk(map, pos, nil)
  end

  defp walk(map, pos, last_pos) do
    map = Map.delete(map, pos)

    open_neighbors(map, pos)
    |> Kernel.--([last_pos])
    |> Enum.flat_map(fn open_pos ->
      walk(map, open_pos, pos)
    end)
  end

  def open_neighbors(map, {x, y}) do
    [{0, -1}, {-1, 0}, {0, 1}, {1, 0}]
    |> Stream.map(fn {dx, dy} ->
      pos = {x + dx, y + dy}
      {pos, map[pos]}
    end)
    |> Stream.filter(fn
      {_, ?@} ->
        true

      {_, nil} ->
        true

      {_, x} when x in ?a..?z ->
        true

      _ ->
        false
    end)
    |> Stream.map(fn {pos, _} -> pos end)
    |> Enum.to_list()
  end
end
