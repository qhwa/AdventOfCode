defmodule AOC.Task.Day17 do
  @moduledoc """
  @see https://adventofcode.com/2015/day/17
  """

  @containers [43, 3, 4, 10, 21, 44, 4, 6, 47, 41, 34, 17, 17, 44, 36, 31, 46, 9, 27, 38]
  @sum 150

  def puzzle() do
    @containers
    |> build_groups([[]])
    |> Enum.filter(&(Enum.sum(&1) == @sum))
    |> length()
  end

  def build_groups([], acc) do
    acc
  end

  def build_groups([size | tail], acc) do
    build_groups(tail, acc |> Enum.flat_map(&[&1, [size | &1]]))
  end
end
