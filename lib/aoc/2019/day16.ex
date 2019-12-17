defmodule AOC.Y2019.Day16 do
  @moduledoc """
  @see https://adventofcode.com/2019/day/16
  """

  for size <- [8, 32, 650], pseed <- 1..size do
    def pos_group(unquote(size), unquote(pseed)) do
      unquote(
        0..size
        |> Enum.chunk_every(pseed)
        |> Enum.drop(1)
        |> Enum.take_every(4)
        |> List.flatten()
      )
    end

    def neg_group(unquote(size), unquote(pseed)) do
      unquote(
        0..size
        |> Enum.chunk_every(pseed)
        |> Enum.drop(3)
        |> Enum.take_every(4)
        |> List.flatten()
      )
    end
  end

  def p1 do
    "priv/data/2019/day16.txt"
    |> File.read!()
    |> String.trim()
    |> String.to_charlist()
    |> Enum.map(&(&1 - ?0))
    |> apply_phase(100)
    |> first_eight_digits()
  end

  def p2 do
    "priv/data/2019/day16.txt"
    |> File.read!()
    |> String.trim()
    |> String.to_charlist()
    |> Enum.map(&(&1 - ?0))
    |> read_message()
  end

  def read_message(digits) do
    offset = digits |> Enum.take(7) |> Integer.undigits()
    digits |> apply_phase(100) |> first_eight_digits(offset)
  end

  def apply_phase(digits, step) when is_list(digits) do
    digits = List.to_tuple(digits)
    size = tuple_size(digits)
    apply_phase(digits, size, step)
  end

  def apply_phase(digits, _, 0), do: digits

  def apply_phase(digits, size, step) do
    1..size
    |> Enum.reduce(digits, fn pseed, acc ->
      pos =
        pos_group(size, pseed)
        |> Enum.map(&elem(digits, &1 - 1))
        |> Enum.sum()

      neg =
        neg_group(size, pseed)
        |> Enum.map(&elem(digits, &1 - 1))
        |> Enum.sum()

      put_elem(acc, pseed - 1, last_digit(pos - neg))
    end)
    |> apply_phase(size, step - 1)
  end

  defp last_digit(n), do: rem(abs(n), 10)

  def first_eight_digits(result, _offset \\ 0) do
    result |> Tuple.to_list() |> Enum.take(8)
  end
end
