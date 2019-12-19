defmodule GameMap do
  @moduledoc """
  Game map parsing and path finding.
  """

  def load_file(path) do
    path
    |> File.read!()
    |> parse()
  end

  @doc """
  Load map from text.
  """
  def parse(source) when is_binary(source) do
    source
    |> String.trim()
    |> String.to_charlist()
    |> parse()
  end

  def parse(src) do
    _parse(src, %{}, 0, 0)
  end

  defp _parse([], map, x, y), do: Enum.into([max_x: x - 1, max_y: y], map)

  defp _parse([?. | rest], map, x, y),
    do: _parse(rest, map, x + 1, y)

  defp _parse([?\n | rest], map, _x, y),
    do: _parse(rest, map, 0, y + 1)

  defp _parse([char | rest], map, x, y),
    do: _parse(rest, Map.put(map, {x, y}, char), x + 1, y)

  def max_x(map) do
    map.max_x
  end

  def max_y(map) do
    map.max_y
  end

  @doc """
  Print out the map on screen.
  """
  def print(map, fill \\ '.') do
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

  @doc """
  Locate a target character on map. Returns the location it is.
  """
  def locate(map, char) do
    case Enum.find(map, &(elem(&1, 1) == char)) do
      {pos, ^char} -> pos
      nil -> nil
    end
  end

  @doc """
  Get all locations
  """
  def locations(map, locater \\ fn _, _, _ -> true end)

  def locations(map, locater) do
    check =
      case Function.info(locater, :arity) do
        {:arity, 1} -> fn p, _, _ -> locater.(p) end
        {:arity, 2} -> fn p, _, map -> locater.(p, map) end
        {:arity, 3} -> &locater.(&1, &2, &3)
      end

    Enum.reduce(map, [], fn
      {{x, y}, v}, acc ->
        if check.({x, y}, v, map), do: [{x, y} | acc], else: acc

      _, acc ->
        acc
    end)
  end

  @doc """
  Get all intersections in a list.
  """
  def intersections(map) do
    GameMap.locations(map, fn {x, y}, v, map ->
      v == ?# and
        map[{x + 1, y}] == ?# and
        map[{x - 1, y}] == ?# and
        map[{x, y + 1}] == ?# and
        map[{x, y - 1}] == ?#
    end)
  end
end
