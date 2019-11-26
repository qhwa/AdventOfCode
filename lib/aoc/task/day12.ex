defmodule AOC.Task.Day12 do
  @moduledoc """
  @see https://adventofcode.com/2015/day/11
  """

  def puzzle() do
    str =
      "priv/data/day12.txt"
      |> File.read!()

    ~r/[-\d]+/
    |> Regex.scan(str)
    |> Enum.reduce(0, fn [n], acc -> acc + String.to_integer(n) end)
  end
end
