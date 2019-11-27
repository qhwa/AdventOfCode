defmodule AOC.Task.Day16 do
  @moduledoc """
  @see https://adventofcode.com/2015/day/16
  """

  @condition [
    children: 3,
    cats: 7,
    samoyeds: 2,
    pomeranians: 3,
    akitas: 0,
    vizslas: 0,
    goldfish: 5,
    trees: 3,
    cars: 2,
    perfumes: 1
  ]

  @condition2 [
    children: 3,
    cats: {:gt, 7},
    samoyeds: 2,
    pomeranians: {:lt, 3},
    akitas: 0,
    vizslas: 0,
    goldfish: {:lt, 5},
    trees: {:gt, 3},
    cars: 2,
    perfumes: 1
  ]

  def puzzle() do
    "priv/data/day16.txt"
    |> File.stream!()
    |> Stream.map(&parse/1)
    |> Stream.filter(fn {_, attrs} ->
      Enum.all?(attrs, fn {k, v} -> Keyword.get(@condition, k) == v end)
    end)
    |> Enum.to_list()
  end

  def puzzle2() do
    "priv/data/day16.txt"
    |> File.stream!()
    |> Stream.map(&parse/1)
    |> Stream.filter(fn {_, attrs} ->
      Enum.all?(attrs, fn {k, v} ->
        value_match?(Keyword.get(@condition2, k), v)
      end)
    end)
    |> Enum.to_list()
  end

  def parse(raw) do
    [_, name, raw_attrs] =
      ~r/(Sue \d+): (.+)$/
      |> Regex.run(raw)

    attrs =
      ~r/(\w+): (\d+)/
      |> Regex.scan(raw_attrs)
      |> Enum.map(fn [_, k, v] ->
        {String.to_atom(k), String.to_integer(v)}
      end)

    {name, attrs}
  end

  def value_match?(x, x), do: true
  def value_match?({:gt, x}, n), do: n > x
  def value_match?({:lt, x}, n), do: n < x
  def value_match?(_, _), do: false
end
