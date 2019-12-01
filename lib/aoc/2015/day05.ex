defmodule AOC.Y2015.Day05 do
  @moduledoc """
  @see https://adventofcode.com/2015/day/5
  """

  def nice_words_count(input) do
    Enum.count(input, &nice?/1)
  end

  def part1_nice?(word) do
    !(word =~ ~r/ab|cd|pq|xy/) &&
      ~r/[aoeiu]/ |> Regex.scan(word) |> length() > 2 &&
      ~r/(.)\1/ |> Regex.match?(word)
  end

  def nice?(word) do
    word =~ ~r/(.{2}).*\1/ &&
      word =~ ~r/(.).\1/
  end
end
