defmodule AOC.Input do
  @moduledoc """
  Helper for dealing input datas.
  """

  @doc """
  Streaming a file

  ## Example

  iex> stream("2019/day01.txt")
  """
  def stream(file) do
    path =
      Path.join([
        :code.priv_dir(:advent_of_code),
        "data",
        file
      ])

    path
    |> File.stream!()
    |> Stream.map(&String.trim_trailing/1)
  end

  @doc """
  Streaming a file with a transformation

  ## Example

  iex> stream("2019/day01.txt", &String.to_integer/1)
  """
  def stream(file, transform) do
    file
    |> stream()
    |> Stream.map(transform)
  end

  def read_integers(file) do
    path =
      Path.join([
        :code.priv_dir(:advent_of_code),
        "data",
        file
      ])

    File.read!(path)
    |> String.trim_trailing()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end
end
