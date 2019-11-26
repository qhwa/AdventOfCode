defmodule AOC.Task.Day09 do
  @moduledoc """
  @see https://adventofcode.com/2015/day/9
  """

  @locations ~w[
    Faerun
    Norrath
    Tristram
    AlphaCentauri
    Arbre
    Snowdin
    Tambi
    Straylight
  ]

  @distances "priv/data/day09.txt"
             |> File.stream!()
             |> Stream.map(fn line ->
               [key, value] =
                 line
                 |> String.trim()
                 |> String.split(" = ")

               {String.to_atom(key), String.to_integer(value)}
             end)
             |> Enum.into(%{})

  # 4!
  def puzzle() do
    @locations
    |> every_order()
    |> walk()
  end

  def every_order([n]) do
    [[n]]
  end

  def every_order(list) when is_list(list) do
    list
    |> Enum.flat_map(fn x ->
      every_order(list |> Enum.reject(&(&1 == x)))
      |> Enum.map(fn order ->
        [x | order]
      end)
    end)
  end

  def walk(orders) do
    orders
    |> Enum.map(&distance/1)
    |> Enum.min_max()
  end

  def distance(order) do
    {dist, _} =
      order
      |> Enum.reduce({0, nil}, fn loc, {acc, prev} ->
        dist = distance_between(prev, loc)
        {acc + dist, loc}
      end)

    dist
  end

  def distance_between(nil, _) do
    0
  end

  def distance_between(a, b) do
    Map.get(@distances, :"#{a} to #{b}") ||
      Map.get(@distances, :"#{b} to #{a}")
  end
end
