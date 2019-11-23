defmodule AOC.Tasks.Day1 do
  @moduledoc """
  @see https://adventofcode.com/2015/day/1#part2
  """

  def resolve(data, floor) do
    find_floor(data, floor, 0, 0)
  end

  def find_floor(_, target, current, step) when target == current do
    step
  end

  def find_floor("", _, _, _) do
    nil
  end

  def find_floor(<<char::binary-size(1), rest::binary>>, target, current, step) do
    case char do
      "(" ->
        find_floor(rest, target, current + 1, step + 1)

      ")" ->
        find_floor(rest, target, current - 1, step + 1)

      _ ->
        find_floor(rest, target, current, step + 1)
    end
  end

  def parse(data) do
    parse_floor(data, 0)
  end

  def parse_floor("", current) do
    current
  end

  def parse_floor(<<char::binary-size(1), rest::binary>>, current) do
    case char do
      "(" ->
        parse_floor(rest, current + 1)

      ")" ->
        parse_floor(rest, current - 1)

      _ ->
        parse_floor(rest, current)
    end
  end
end
