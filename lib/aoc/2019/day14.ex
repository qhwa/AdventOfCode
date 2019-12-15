defmodule AOC.Y2019.Day14 do
  @moduledoc """
  @see https://adventofcode.com/2019/day/14
  """
  def p1 do
    {ores, _leftover} = ore_required(parse_reactions(), :FUEL, 1)
    ores
  end

  @max_ore 1_000_000_000_000

  def p2 do
    reactions = parse_reactions()
    price = p1()

    min = div(@max_ore, price)
    max = @max_ore

    binary_search(min, max, reactions)
  end

  defp binary_search(min, max, _reactions) when min > max, do: max

  defp binary_search(min, max, reactions) do
    amount = div(min + max, 2)

    {required, _} = ore_required(reactions, :FUEL, amount)

    if required > @max_ore do
      binary_search(min, amount - 1, reactions)
    else
      binary_search(amount + 1, max, reactions)
    end
  end

  def parse_reactions do
    AOC.Input.stream("2019/day14.txt", &parse_reaction/1)
    |> Enum.into(%{})
  end

  @doc """
  Parse reaction formula.

  ## Example

      iex> parse_reaction("9 ORE => 2 A")
      {:A, {[ORE: 9], 2}}

      iex> parse_reaction("2 AB, 3 BC, 4 CA => 1 FUEL")
      {:FUEL, {[AB: 2, BC: 3, CA: 4], 1}}
  """
  def parse_reaction(src) do
    [{name, n} | tail] =
      ~r/(\d+) (\w+)/
      |> Regex.scan(src)
      |> Enum.map(fn [_, n, name] ->
        {String.to_atom(name), String.to_integer(n)}
      end)
      |> Enum.reverse()

    {name, {Enum.reverse(tail), n}}
  end

  defp ore_required(reactions, target, amount, leftover \\ %{})
  defp ore_required(_, :ORE, amount, leftover), do: {amount, leftover}

  defp ore_required(reactions, target, amount, leftover) do
    {materials, least_amount} = Map.fetch!(reactions, target)

    {existing, leftover} = recyle(leftover, target, amount)
    amount = amount - existing

    m = ceil(amount / least_amount)
    wasted = least_amount * m - amount

    leftover =
      if wasted > 0 do
        Map.update(leftover, target, wasted, &(&1 + wasted))
      else
        leftover
      end

    {required, leftover} =
      materials
      |> Enum.reduce({0, leftover}, fn {name, n}, {sum, leftover} ->
        {r, l} = ore_required(reactions, name, n * m, leftover)
        {sum + r, l}
      end)

    {required, leftover}
  end

  defp recyle(leftover, target, amount) do
    case Map.get(leftover, target) do
      nil ->
        {0, leftover}

      n ->
        provide = min(n, amount)
        {provide, %{leftover | target => n - provide}}
    end
  end
end
