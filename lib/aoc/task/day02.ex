defmodule AOC.Task.Day02 do
  @moduledoc """
  @see https://adventofcode.com/2015/day/2
  """

  def feet_of_wrapping_paper({:file, file}) do
    file
    |> File.stream!()
    |> Enum.to_list()
    |> feet_of_wrapping_paper()
  end

  def feet_of_wrapping_paper(list) when is_list(list) do
    list
    |> Enum.reduce(0, fn item, acc ->
      acc + feet_of_wrapping_paper(item)
    end)
  end

  def feet_of_wrapping_paper(data) when is_binary(data) do
    [l, w, h] =
      data
      |> String.trim()
      |> String.split("x")
      |> Enum.map(&String.to_integer/1)

    feet_of_wrapping_paper({l, w, h})
  end

  def feet_of_wrapping_paper({l, w, h}) when is_number(l) and is_number(w) and is_number(h) do
    2 * l * w + 2 * w * h + 2 * l * h + smallest_surface(l, w, h)
  end

  def smallest_surface(l, w, h) do
    if l < w do
      l * min(w, h)
    else
      w * min(l, h)
    end
  end

  def feet_of_ribbon({:file, file}) do
    file
    |> File.stream!()
    |> Enum.to_list()
    |> feet_of_ribbon()
  end

  def feet_of_ribbon(data) when is_binary(data) do
    [l, w, h] =
      data
      |> String.trim()
      |> String.split("x")
      |> Enum.map(&String.to_integer/1)

    feet_of_ribbon({l, w, h})
  end

  def feet_of_ribbon([]) do
    0
  end

  def feet_of_ribbon([item | tail]) do
    feet_of_ribbon(item) + feet_of_ribbon(tail)
  end

  def feet_of_ribbon({l, w, h}) do
    smallest_sides(l, w, h) * 2 + l * w * h
  end

  defp smallest_sides(l, w, h) do
    if l < w do
      l + min(w, h)
    else
      w + min(l, h)
    end
  end
end
