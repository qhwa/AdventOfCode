defmodule AOC.Y2019.Day06 do
  @moduledoc """
  @see https://adventofcode.com/2019/day/6
  """

  def p1, do: File.read!("priv/data/2019/day06.txt") |> parse() |> walk(:COM)
  def p2, do: nil

  def example do
    input = """
    COM)B
    B)C
    C)D
    D)E
    E)F
    B)G
    G)H
    D)I
    E)J
    J)K
    K)L
    """

    input
    |> parse()
    |> walk(:COM)
  end

  def parse(str) do
    str
    |> String.trim()
    |> String.split()
    |> Stream.map(&String.split(&1, ")"))
    |> Stream.map(fn arr -> Enum.map(arr, &String.to_atom/1) end)
    |> Enum.reduce(%{}, fn [c, a], map ->
      map
      |> Map.update(c, %{children: [a]}, fn obj ->
        %{obj | children: [a | obj.children]}
      end)
      |> Map.put_new(a, %{children: []})
    end)
  end

  def walk(map, name) do
    node = map[name]

    {n1, n2} =
      node.children
      |> Enum.reduce({0, 0}, fn n, {c1, c2} ->
        {a, b} = walk(map, n)
        {c1 + a, c2 + b}
      end)

    {length(node.children) + n1, n1 + n2}
  end
end
