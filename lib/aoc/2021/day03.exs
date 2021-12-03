defmodule Y2021.Day03 do
  @moduledoc """
  https://adventofcode.com/2021/day/3

  Run with: `mix run lib/aoc/2021/day03.exs`
  """

  use Bitwise

  def part1 do
    AOC.Input.stream("2021/day03.txt", &String.to_charlist/1)
    |> Enum.zip_reduce([], &[most_common_digit(&1) | &2])
    |> Enum.reverse()
    |> then(fn digits ->
      gamma = Integer.undigits(digits, 2)
      epsilong = (2 <<< (Enum.count(digits) - 1)) - gamma - 1

      gamma * epsilong
    end)
  end

  def part2 do
    numbers =
      AOC.Input.stream("2021/day03.txt", &String.to_integer(&1, 2))
      |> Enum.to_list()

    ox =
      numbers
      |> filter(fn n, mask, common_bit ->
        (mask &&& n) == common_bit * mask
      end)

    co2 =
      numbers
      |> filter(fn n, mask, common_bit ->
        (mask &&& n) != common_bit * mask
      end)

    ox * co2
  end

  defp most_common_digit(digits) do
    case Enum.frequencies(digits) do
      %{?0 => z, ?1 => o} when z > o ->
        0

      _ ->
        1
    end
  end

  defp filter(numbers, checker),
    do: filter(numbers, checker, mask(numbers))

  defp filter([_, _ | _] = numbers, checker, mask) do
    common_bit = common_bit(numbers, mask)

    numbers
    |> Enum.filter(&checker.(&1, mask, common_bit))
    |> filter(checker, mask >>> 1)
  end

  defp filter([n], _, _), do: n

  defp mask(numbers) when is_list(numbers),
    do: Enum.max(numbers) |> mask(1)

  defp mask(0, mask), do: mask >>> 1
  defp mask(number, mask), do: mask(number >>> 1, mask <<< 1)

  defp common_bit(numbers, mask) do
    numbers
    |> Stream.map(&(&1 &&& mask))
    |> Enum.frequencies()
    |> case do
      %{0 => z, ^mask => o} when z > o ->
        0

      _ ->
        1
    end
  end
end

Y2021.Day03.part1() |> IO.inspect(label: "part 1")
Y2021.Day03.part2() |> IO.inspect(label: "part 2")
