defmodule AOC.Task.Day07 do
  use Bitwise
  use Agent

  @moduledoc """
  @see https://adventofcode.com/2015/day/7
  """

  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: __MODULE__, debug: [:log])
  end

  def cached_value(wire) do
    Agent.get(__MODULE__, &Map.get(&1, wire))
  end

  def cache(wire, value) do
    Agent.update(__MODULE__, &Map.put(&1, wire, value))
    value
  end

  def puzzle(file \\ "priv/data/day07.txt") do
    circuit =
      file
      |> File.stream!()
      |> Enum.to_list()
      |> parse()

    start_link(circuit)

    find_value(circuit, :a)
  end

  def parse(data) when is_list(data) do
    Enum.reduce(data, %{}, fn conn, acc ->
      {wire, flow} = parse(conn)
      Map.put(acc, wire, flow)
    end)
  end

  def parse(data) when is_binary(data) do
    [input, wire] =
      data
      |> String.trim()
      |> String.split(" -> ")

    input =
      input
      |> String.trim()
      |> String.split(" ")

    {:"#{wire}", parse_input(input)}
  end

  defp parse_input([a, "OR", b]), do: {:or, [parse_input(a), parse_input(b)]}
  defp parse_input([a, "AND", b]), do: {:and, [parse_input(a), parse_input(b)]}
  defp parse_input(["NOT", a]), do: {:not, parse_input(a)}
  defp parse_input([a, "RSHIFT", n]), do: {:">>", parse_input(a), String.to_integer(n)}
  defp parse_input([a, "LSHIFT", n]), do: {:"<<", parse_input(a), String.to_integer(n)}
  defp parse_input([int]), do: parse_input(int)

  defp parse_input(int) do
    if int =~ ~r/^\d+$/ do
      String.to_integer(int)
    else
      :"#{int}"
    end
  end

  def find_value(circuit, wire) when is_atom(wire) do
    case cached_value(wire) do
      nil ->
        value = find_value(circuit, Map.fetch!(circuit, wire))
        cache(wire, value)

      value ->
        value
    end
  end

  def find_value(circuit, {:or, [a, b]}) do
    v1 = find_value(circuit, a)
    v2 = find_value(circuit, b)
    bor(v1, v2)
  end

  def find_value(circuit, {:and, [a, b]}) do
    v1 = find_value(circuit, a)
    v2 = find_value(circuit, b)
    v1 &&& v2
  end

  def find_value(circuit, {:not, a}) do
    65_535 - find_value(circuit, a)
  end

  def find_value(circuit, {:">>", a, dist}) do
    find_value(circuit, a) >>> dist
  end

  def find_value(circuit, {:"<<", a, dist}) do
    find_value(circuit, a) <<< dist
  end

  def find_value(_, value) when is_integer(value) do
    value
  end
end
