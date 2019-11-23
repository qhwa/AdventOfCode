defmodule AOC.Task.Day2 do
  @moduledoc """
  @see https://adventofcode.com/2015/day/2
  """

  def resolve({:file, file}) do
    file
    |> File.stream!()
  end

  def resolve(list) when is_list(list) do
    list
    |> Enum.reduce(0, fn item, acc -> acc + resolve(item) end)
  end

  def resolve(data) when is_binary(data) do
    [l, w, h] =
      data
      |> String.split("x")
      |> Enum.map(&String.to_integer/1)

    resolve({l, w, h})
  end

  def resolve({l, w, h}) when is_number(l) and is_number(w) and is_number(h) do
    2 * l * w + 2 * w * h + 2 * l * h + smallest_surface(l, w, h)
  end

  def smallest_surface(l, w, h) do
    if l < w do
      l * min(w, h)
    else
      w * min(l, h)
    end
  end
end
