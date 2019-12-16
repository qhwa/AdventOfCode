defmodule AOC.Y2019.Day16 do
  @moduledoc """
  @see https://adventofcode.com/2019/day/16
  """

  import Helper.MyList, only: [to_map: 1]

  for len <- [8, 32, 650], pseed <- 1..len do
    def pos_group(unquote(len), unquote(pseed)) do
      unquote(
        0..len
        |> Enum.chunk_every(pseed)
        |> Enum.drop(1)
        |> Enum.take_every(4)
        |> List.flatten()
      )
    end

    def neg_group(unquote(len), unquote(pseed)) do
      unquote(
        0..len
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
    apply_phase(to_map(digits), Enum.count(digits), step)
  end

  def apply_phase(digits, _, 0), do: digits

  def apply_phase(digits, len, step) do
    1..len
    |> Enum.map(fn pseed ->
      last_digit(
        Enum.sum(pos_group(len, pseed) |> Enum.map(&digits[&1 - 1])) -
          Enum.sum(neg_group(len, pseed) |> Enum.map(&digits[&1 - 1]))
      )
    end)
    |> apply_phase(step - 1)
  end

  defp last_digit(n) do
    rem(abs(n), 10)
  end

  def first_eight_digits(map, offset \\ 0) do
    0..7 |> Enum.map(&map[&1 + offset])
  end
end
