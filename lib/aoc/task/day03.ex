defmodule AOC.Task.Day03 do
  @moduledoc """
  @see https://adventofcode.com/2015/day/3
  """

  def houses_visit({:file, file}) do
    file
    |> File.read!()
    |> houses_visit()
  end

  def houses_visit(data) do
    houses_visit(data, [0, 0], %{:"0_0" => 1}, 1)
  end

  def houses_visit("", _, _, count), do: count

  def houses_visit(<<dir::binary-size(1), rest::binary>>, pos, map, count) do
    pos = pos |> new_pos(dir)
    key = pos |> Enum.join("_") |> String.to_atom()

    if Map.has_key?(map, key) do
      houses_visit(rest, pos, map, count)
    else
      houses_visit(rest, pos, Map.put(map, key, 1), count + 1)
    end
  end

  defp new_pos([x, y], "^"), do: [x, y - 1]
  defp new_pos([x, y], "v"), do: [x, y + 1]
  defp new_pos([x, y], "<"), do: [x - 1, y]
  defp new_pos([x, y], ">"), do: [x + 1, y]
end
