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
    houses_visit(data, [0, 0], %{:"0_0" => 1})
  end

  def houses_visit("", _, map), do: Map.keys(map) |> length()

  def houses_visit(<<dir::binary-size(1), rest::binary>>, pos, map) do
    pos = pos |> new_pos(dir)
    houses_visit(rest, pos, record_visit(map, pos))
  end

  defp record_visit(map, pos) do
    map
    |> Map.put_new(key(pos), 1)
  end

  defp key(pos) do
    pos
    |> Enum.join("_")
    |> String.to_atom()
  end

  defp new_pos([x, y], "^"), do: [x, y - 1]
  defp new_pos([x, y], "v"), do: [x, y + 1]
  defp new_pos([x, y], "<"), do: [x - 1, y]
  defp new_pos([x, y], ">"), do: [x + 1, y]

  defp new_pos([x, y], ?^), do: [x, y - 1]
  defp new_pos([x, y], ?v), do: [x, y + 1]
  defp new_pos([x, y], ?<), do: [x - 1, y]
  defp new_pos([x, y], ?>), do: [x + 1, y]

  defp new_pos(pos, _), do: pos

  def houses_visit_with_robot(data) do
    {santa_data, robot_data} = split_data(data)

    santa_map = houses_visit_with_robot(santa_data, [0, 0], %{:"0_0" => 1})
    robot_map = houses_visit_with_robot(robot_data, [0, 0], %{:"0_0" => 1})

    santa_map
    |> Map.merge(robot_map)
    |> Map.keys()
    |> length()
  end

  def houses_visit_with_robot([], _, map), do: map

  # Santa moves first
  def houses_visit_with_robot([dir | rest], pos, map) do
    pos = pos |> new_pos(dir)
    houses_visit_with_robot(rest, pos, record_visit(map, pos))
  end

  defp split_data(data) when is_binary(data) do
    data
    |> String.to_charlist()
    |> split_data()
  end

  defp split_data(data) when is_list(data) do
    split_data(data, [], [])
  end

  defp split_data([santa_dir, robot_dir | tail], santa, robot) do
    split_data(tail, santa ++ [santa_dir], robot ++ [robot_dir])
  end

  defp split_data([santa_dir | tail], santa, robot) do
    split_data(tail, santa ++ [santa_dir], robot)
  end

  defp split_data([], santa, robot) do
    {santa, robot}
  end
end
