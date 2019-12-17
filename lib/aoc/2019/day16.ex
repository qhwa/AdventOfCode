defmodule AOC.Y2019.Day16 do
  @moduledoc """
  @see https://adventofcode.com/2019/day/16
  """

  use Bitwise

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
      ret = walk(digits, size, pseed)
      put_elem(acc, pseed - 1, last_digit(ret))
    end)
    |> apply_phase(step - 1)
  end

  defp walk(digits, size, pseed, acc \\ 0, id \\ 0)

  defp walk(_digits, size, _pseed, acc, id) when id >= size, do: acc

  defp walk(digits, size, 1, _, 0) do
    walk(digits, size, 1, elem(digits, 0), 1)
  end

  defp walk(digits, size, pseed, _, 0) do
    walk(digits, size, pseed, 0, pseed - 1)
  end

  defp walk(digits, size, pseed, acc, id) do
    f = div(id + 1, pseed) &&& 0b11

    case f do
      0 ->
        walk(digits, size, pseed, acc, id + pseed)

      1 ->
        walk(digits, size, pseed, acc + elem(digits, id), id + 1)

      2 ->
        walk(digits, size, pseed, acc, id + pseed)

      3 ->
        walk(digits, size, pseed, acc - elem(digits, id), id + 1)
    end
  end

  defp last_digit(n), do: rem(abs(n), 10)

  def first_eight_digits(result, offset \\ 0),
    do: for(i <- 0..7, do: elem(result, offset + i))
end
