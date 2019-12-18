defmodule GameMap do
  @moduledoc """
  Game map parsing and path finding.
  """

  def load_file(path) do
    path
    |> File.read!()
    |> load()
  end

  @doc """
  Load map from text.
  """
  def load(source) when is_binary(source) do
    source
    |> String.trim()
    |> String.to_charlist()
    |> load()
  end

  def load(source) when is_list(source), do: parse(source)

  defp parse(src, map \\ %{}, x \\ 0, y \\ 0)
  defp parse([], map, _x, _y), do: map

  defp parse([?\n | rest], map, _x, y),
    do: parse(rest, map, 0, y + 1)

  defp parse([char | rest], map, x, y),
    do: parse(rest, Map.put(map, {x, y}, char), x + 1, y)

  def max_x(map) do
    {{x, _}, _} = map |> Enum.max_by(fn {{x, _}, _} -> x end)
    x
  end

  def max_y(map) do
    {{_, y}, _} = map |> Enum.max_by(fn {{_, y}, _} -> y end)
    y
  end

  @doc """
  Print out the map on screen.
  """
  def print(map, fill \\ ' ') do
    0..max_y(map)
    |> Enum.map(fn y ->
      0..max_x(map)
      |> Enum.map(fn x ->
        Map.get(map, {x, y}, fill)
      end)
    end)
    |> Enum.intersperse(?\n)
    |> IO.puts()
  end

  def locate(map, char) do
    case Enum.find(map, &(elem(&1, 1) == char)) do
      {pos, ^char} -> pos
      nil -> nil
    end
  end
end
