defmodule AOC.Y2019.Day16 do
  @moduledoc """
  @see https://adventofcode.com/2019/day/16
  """

  for size <- [8, 650, 6_500_000], pseed <- 1..size do
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

  def pos_group(size, pseed) do
    0..size
    |> Enum.chunk_every(pseed)
    |> Enum.drop(1)
    |> Enum.take_every(4)
    |> List.flatten()
  end

  def neg_group(size, pseed) do
    0..size
    |> Enum.chunk_every(pseed)
    |> Enum.drop(3)
    |> Enum.take_every(4)
    |> List.flatten()
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
    |> List.duplicate(10_000)
    |> read_message()
  end

  def read_message(digits) do
    offset = digits |> Enum.take(7) |> Integer.undigits()
    digits |> apply_phase(100) |> first_eight_digits(offset)
  end

  def apply_phase(digits, step) when is_list(digits) do
    digits = List.to_tuple(digits)
    apply_phase(digits, step)
  end

  def apply_phase(digits, 0), do: digits

  def apply_phase(digits, step) do
    size = tuple_size(digits)

    1..size
    |> Enum.reduce(digits, fn pseed, acc ->
      pos =
        pos_group(size, pseed)
        |> Enum.reduce(0, &(elem(digits, &1 - 1) + &2))

      neg =
        neg_group(size, pseed)
        |> Enum.reduce(0, &(elem(digits, &1 - 1) + &2))

      put_elem(acc, pseed - 1, last_digit(pos - neg))
    end)
    |> apply_phase(step - 1)
  end

  defp last_digit(n), do: rem(abs(n), 10)

  def first_eight_digits(result, offset \\ 0) do
    0..7 |> Enum.map(&elem(result, offset + &1))
  end
end
