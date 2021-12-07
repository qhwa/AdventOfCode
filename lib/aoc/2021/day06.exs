defmodule Y2021.Day06 do
  @moduledoc """
  https://adventofcode.com/2021/day/6

  Run with: `mix run lib/aoc/2021/day06.exs`
  """
  def p1 do
    resolve(80)
  end

  def p2 do
    resolve(256)
  end

  defp resolve(days) do
    Agent.start_link(fn -> %{} end, name: :memorized)

    cache = build_cache(days)

    input()
    |> Stream.map(&Map.get(cache, &1))
    |> Enum.sum()
  end

  defp input do
    File.read!("priv/data/2021/day06.txt")
    |> String.trim_trailing("\n")
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  defp build_cache(days) do
    8..1
    |> Stream.map(&{&1, f(&1, days)})
    |> Enum.into(%{})
  end

  defp compute(days) do
    case days do
      n when n in 0..8 ->
        1

      n when is_integer(n) and n > 8 ->
        (n - 2 - 7)..0//-7
        |> Stream.map(&f/1)
        |> Enum.sum()
        |> Kernel.+(1)
    end
  end

  @doc """
  Given an amount of days, returning how many fishes there
  will be after.
  """
  def f(days) do
    case Agent.get(:memorized, &Map.get(&1, days)) do
      value when is_integer(value) ->
        value

      nil ->
        compute(days)
        |> tap(fn value ->
          Agent.update(:memorized, &Map.put(&1, days, value))
        end)
    end
  end

  def f(init_day, days) when init_day in 0..8 do
    f(days - init_day + 8)
  end

  def test do
    0..8 |> Enum.each(fn n -> 1 = f(n) end)
    9..15 |> Enum.each(fn n -> 2 = f(n) end)
    16..17 |> Enum.each(fn n -> 3 = f(n) end)
    18..22 |> Enum.each(fn n -> 4 = f(n) end)
    23..24 |> Enum.each(fn n -> 5 = f(n) end)
    7 = f(25)
  end
end

Y2021.Day06.p1() |> IO.inspect(label: "part 1")
Y2021.Day06.p2() |> IO.inspect(label: "part 2")
