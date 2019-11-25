defmodule AOC.Task.Day08 do
  @moduledoc """
  @see https://adventofcode.com/2015/day/8
  """

  def puzzle() do
    "priv/data/day08.txt"
    |> File.stream!()
    |> Enum.to_list()
    |> Enum.reduce({0, 0}, fn raw, {code_len, mem_len} ->
      {c, m} = parse(raw |> String.trim_trailing())
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
end
