defmodule AOC.Y2019.Day16 do
  @moduledoc """
  @see https://adventofcode.com/2019/day/16
  """

  import Helper.MyList, only: [to_map: 1]

  def p1 do
    "priv/data/2019/day16.txt"
    |> File.read!()
    |> String.trim()
    |> String.to_charlist()
    |> Enum.map(&(&1 - ?0))
    |> apply_phase(100)
  end

  def p2 do
  end

  def apply_phase(digits, step) when is_list(digits) do
    apply_phase(to_map(digits), Enum.count(digits), step)
  end

  def apply_phase(digits, _, 0), do: Enum.map(0..7, &digits[&1])

  def apply_phase(digits, len, step) do
    1..len
    |> Enum.map(fn pseed ->
      digest(digits, len, pseed, 0)
    end)
    |> apply_phase(step - 1)
  end

  defp digest(_, 0, _, acc), do: last_digit(acc)

  defp digest(digits_map, i, pseed, acc) do
    case friction(pseed, i - 1) do
      0 ->
        digest(digits_map, i - 1, pseed, acc)

      n ->
        digest(digits_map, i - 1, pseed, acc + n * Map.fetch!(digits_map, i - 1))
    end
  end

  defp friction(pseed, id) do
    case rem(div(id + 1, pseed), 4) do
      0 -> 0
      1 -> 1
      2 -> 0
      3 -> -1
    end
  end

  defp last_digit(n) do
    rem(abs(n), 10)
  end
end
