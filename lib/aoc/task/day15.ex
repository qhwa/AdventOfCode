defmodule AOC.Task.Day15 do
  @moduledoc """
  @see https://adventofcode.com/2015/day/15
  """

  @ingredients [
    Frosting: {4, -2, 0, 0, 5},
    Candy: {0, 5, -1, 0, 8},
    Butterscotch: {-1, 0, 5, 0, 6},
    Sugar: {0, 0, -2, 2, 1}
  ]

  def puzzle() do
    @ingredients
    |> Keyword.keys()
    |> possible_groups(100)
    |> Enum.map(&score/1)
    |> Enum.max_by(fn {_, score} -> score end)
  end

  def possible_groups([], _) do
    []
  end

  def possible_groups(_, n) when n <= 0 do
    []
  end

  def possible_groups([item], n) do
    [[{item, n}]]
  end

  def possible_groups([head | tail], total) do
    0..total
    |> Enum.flat_map(fn n ->
      tail
      |> possible_groups(total - n)
      |> Enum.map(&[{head, n} | &1])
    end)
  end

  def score(group) do
    {sum_cap, sum_dur, sum_fla, sum_txt} =
      group
      |> Enum.reduce({0, 0, 0, 0}, fn {ing, n}, {s1, s2, s3, s4} ->
        {i1, i2, i3, i4, _} = Keyword.get(@ingredients, ing)

        {
          s1 + i1 * n,
          s2 + i2 * n,
          s3 + i3 * n,
          s4 + i4 * n
        }
      end)

    total = max(sum_cap, 0) * max(sum_dur, 0) * max(sum_fla, 0) * max(sum_txt, 0)
    {group, total}
  end
end
