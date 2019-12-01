defmodule AOC.Y2015.Day08 do
  @moduledoc """
  @see https://adventofcode.com/2015/day/8
  """

  @parse_f :parse2

  def puzzle() do
    "priv/data/2015/day08.txt"
    |> File.stream!()
    |> Enum.to_list()
    |> Enum.reduce({0, 0}, fn raw, {code_len, mem_len} ->
      {c, m} = apply(__MODULE__, @parse_f, [raw |> String.trim_trailing()])
      {code_len + c, mem_len + m}
    end)
  end

  @doc """
  Parse string length in code, and length in memory.

  ## Example

  iex> parse("")
  {0, 0}

  iex> parse(~S{""})
  {2, 0}

  iex> parse(~S{"abc"})
  {5, 3}
  """
  def parse(str) do
    mem_len =
      str
      |> String.replace(~r/^"(.*)"$/, "\\1")
      |> String.replace(~r/\\\\/, "_")
      |> String.replace(~r/\\x[A-Fa-f0-9]{2}/, "_")
      |> String.replace(~r/\\"/, "_")
      |> String.length()

    {str |> String.length(), mem_len}
  end

  def parse2(str) do
    mem_len =
      str
      |> String.replace(~r/^"|"$/, "")
      |> String.replace(~r/\\\\/, "____")
      |> String.replace(~r/\\x[A-Fa-f0-9]{2}/, "_____")
      |> String.replace(~r/\\"/, "____")
      |> String.length()

    {str |> String.length(), mem_len + 6}
  end
end
