defmodule AOC.Task.Day12 do
  @moduledoc """
  @see https://adventofcode.com/2015/day/11
  """

  def puzzle() do
    "priv/data/day12.txt"
    |> File.read!()
    |> Jason.decode!()
    |> walk()
  end

  def walk(%{} = obj) do
    if valid?(obj) do
      Enum.reduce(obj, 0, fn {_, v}, acc ->
        walk(v) + acc
      end)
    else
      0
    end
  end

  def walk(prim) when is_integer(prim) do
    prim
  end

  def walk(list) when is_list(list) do
    Enum.reduce(list, 0, fn item, acc -> acc + walk(item) end)
  end

  def walk(str) when is_binary(str) do
    0
  end

  def walk(_) do
    0
  end

  def valid?(obj) do
    obj
    |> Map.values()
    |> Enum.member?("red")
    |> Kernel.!()
  end
end
