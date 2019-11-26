defmodule AOC.Task.Day11 do
  @moduledoc """
  @see https://adventofcode.com/2015/day/11
  """

  def puzzle() do
    "hxbxxyzz"
    |> next_password()
    |> increase()
    |> next_password()
  end

  def next_password(curr) do
    if valid?(curr) do
      curr
    else
      curr |> increase() |> next_password()
    end
  end

  @reg ?a..?x
       |> Enum.reduce([], fn char, acc ->
         [<<char, char + 1, char + 2>> | acc]
       end)
       |> Enum.reverse()
       |> Enum.join("|")
       |> Regex.compile!()

  @invalid_reg ~r/[iol]/

  @doc """
  Check wether password is valid.

  ## Examples

  iex> valid?("hijklmmn")
  false

  iex> valid?("abbceffg")
  false

  iex> valid?("abbcegjk")
  false

  iex> valid?("abcdffaa")
  true

  iex> valid?("hxbxwxyy")
  false
  """
  def valid?(pwd) do
    Regex.match?(@reg, pwd) &&
      with_pairs?(pwd) &&
      !Regex.match?(@invalid_reg, pwd)
  end

  defp with_pairs?(pwd) do
    case Regex.scan(~r/(.)\1/, pwd, capture: :first) do
      [] ->
        false

      arr ->
        len =
          arr
          |> List.flatten()
          |> Enum.uniq()
          |> length()

        len > 1
    end
  end

  def increase(curr) do
    curr
    |> decode()
    |> Kernel.+(1)
    |> encode()
  end

  def decode(str) do
    str
    |> String.to_charlist()
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.reduce(0, fn {x, i}, acc ->
      (x - ?a) * floor(:math.pow(26, i)) + acc
    end)
  end

  def encode(n) do
    encode(n, [])
  end

  def encode(0, []) do
    "a"
  end

  def encode(0, arr) do
    arr
    |> Enum.map(&<<&1 + ?a>>)
    |> Enum.join("")
  end

  def encode(n, arr) do
    encode(div(n, 26), [rem(n, 26) | arr])
  end
end
