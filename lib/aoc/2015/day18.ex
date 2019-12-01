defmodule AOC.Y2015.Day18 do
  @moduledoc """
  @see https://adventofcode.com/2015/day/18
  """

  @init_state "priv/data/2015/day18.txt"
              |> File.stream!()
              |> Stream.with_index()
              |> Stream.map(fn {line, y} ->
                line
                |> String.trim_trailing()
                |> String.to_charlist()
                |> Enum.with_index()
                |> Enum.map(fn {char, x} -> {:"#{x}_#{y}", {x, y, char}} end)
              end)
              |> Enum.to_list()
              |> List.flatten()
              |> Enum.into(%{})

  @step 100
  @size 100

  def puzzle() do
    @init_state
    |> run_after(@step, @size)
    |> count_light
  end

  def run_after(state, step, size) do
    1..step
    |> Enum.reduce(state, fn _, s -> next(s, size) end)
  end

  def next(state, size) do
    Enum.reduce(state, state, fn {key, {x, y, current}}, acc ->
      max = size - 1

      neighbors9 =
        for i <- (x - 1)..(x + 1), j <- (y - 1)..(y + 1), i >= 0, j >= 0, i < size, j < size do
          if light?(i, j, Map.get(state, :"#{i}_#{j}"), max), do: 1, else: 0
        end
        |> Enum.sum()

      case next_single_light(current, neighbors9, x, y, max) do
        ^current ->
          acc

        other ->
          acc |> Map.put(key, {x, y, other})
      end
    end)
  end

  defp light?(0, 0, _, _), do: true
  defp light?(0, max, _, max), do: true
  defp light?(max, max, _, max), do: true
  defp light?(max, 0, _, max), do: true
  defp light?(_, _, {_, _, ?#}, _), do: true
  defp light?(_, _, _, _), do: false

  defp next_single_light(_, _, 0, 0, _), do: ?#
  defp next_single_light(_, _, 0, max, max), do: ?#
  defp next_single_light(_, _, max, 0, max), do: ?#
  defp next_single_light(_, _, max, max, max), do: ?#
  defp next_single_light(?#, 3, _, _, _), do: ?#
  defp next_single_light(?#, 4, _, _, _), do: ?#
  defp next_single_light(?., 3, _, _, _), do: ?#
  defp next_single_light(_, _, _, _, _), do: ?.

  def count_light(state) do
    state
    |> Enum.count(fn {_, {_, _, s}} -> s == ?# end)
  end

  def encode(state, size) do
    1..size
    |> Enum.map(fn y ->
      1..size
      |> Enum.map(fn x ->
        {_, _, char} = Map.get(state, :"#{x - 1}_#{y - 1}")
        <<char>>
      end)
      |> Enum.join("")
    end)
    |> Enum.join("\n")
  end
end
