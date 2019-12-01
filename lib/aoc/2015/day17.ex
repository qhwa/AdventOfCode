defmodule AOC.Y2015.Day17 do
  @moduledoc """
  @see https://adventofcode.com/2015/day/17
  """

  @containers [43, 3, 4, 10, 21, 44, 4, 6, 47, 41, 34, 17, 17, 44, 36, 31, 46, 9, 27, 38]
  @sum 150

  def puzzle() do
    @containers
    |> build_groups([[]])
    |> Enum.filter(&(Enum.sum(&1) == @sum))
  end

  def puzzle2() do
    solutions = puzzle()

    min_len =
      solutions
      |> Enum.min_by(&length/1)
      |> length()

    solutions
    |> Enum.filter(&(length(&1) == min_len))
  end

  def build_groups([], acc) do
    acc
  end

  def build_groups([size | tail], acc) do
    build_groups(tail, acc |> Enum.flat_map(&[&1, [size | &1]]))
  end
end
