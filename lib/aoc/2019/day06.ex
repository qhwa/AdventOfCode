defmodule AOC.Y2019.Day06 do
  @moduledoc """
  @see https://adventofcode.com/2019/day/6
  """

  import Enum, only: [map: 2, reduce: 3, find_index: 2, reverse: 1]

  def p1, do: read_input() |> walk(:COM)
  def p2, do: read_input() |> min_distance(:YOU, :SAN)

  def read_input do
    File.read!("priv/data/2019/day06.txt")
    |> parse()
  end

  def parse(str) do
    str
    |> String.trim()
    |> String.split()
    |> Stream.map(&String.split(&1, ")"))
    |> Stream.map(fn arr -> map(arr, &String.to_atom/1) end)
    |> reduce(%{}, fn [c, a], map ->
      map
      |> Map.update(c, %{children: [a], parent: nil}, &%{&1 | children: [a | &1.children]})
      |> Map.update(a, %{children: [], parent: c}, &%{&1 | parent: c})
    end)
  end

  def walk(map, name) do
    node = map[name]

    {n1, n2} =
      node.children
      |> reduce({0, 0}, fn n, {c1, c2} ->
        {a, b} = walk(map, n)
        {c1 + a, c2 + b}
      end)

    {length(node.children) + n1, n1 + n2}
  end

  def min_distance(map, a, b) do
    path1 = ancestors(map, a)
    path2 = ancestors(map, b)

    for p <- path1, p in path2 do
      find_index(path1, &(&1 == p)) + find_index(path2, &(&1 == p))
    end
    |> Enum.min()
    |> Kernel.-(2)
  end

  def ancestors(map, start), do: ancestors(map, start, [])
  def ancestors(_map, nil, path), do: reverse(path)

  def ancestors(map, current, path) do
    ancestors(
      map,
      Map.get(map[current], :parent),
      [current | path]
    )
  end
end
