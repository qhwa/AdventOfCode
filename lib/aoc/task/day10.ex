defmodule AOC.Task.Day10 do
  @moduledoc """
  @see https://adventofcode.com/2015/day/10
  """

  def puzzle() do
    1..40
    |> Enum.reduce("3113322113", fn _, acc ->
      look_and_say(acc)
    end)
  end

  @doc """
  implement the `look_and_say` method.

  ## Examples

  iex> look_and_say("211")
  "1221"

  iex> look_and_say("1")
  "11"

  iex> look_and_say("11")
  "21"

  iex> look_and_say("1211")
  "111221"

  iex> look_and_say("111221")
  "312211"
  """
  def look_and_say(text) do
    text
    |> String.to_charlist()
    |> scan([])
    |> Enum.reverse()
    |> encode()
  end

  defp scan([], ret) do
    ret
  end

  defp scan([head | rest], [{head, count} | tail]) do
    scan(rest, [{head, count + 1} | tail])
  end

  defp scan([head | rest], ret) do
    scan(rest, [{head, 1} | ret])
  end

  defp encode(data) do
    data
    |> Enum.reduce("", fn {int, count}, acc ->
      "#{acc}#{count}#{<<int>>}"
    end)
  end
end
