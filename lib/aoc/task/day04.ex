defmodule AOC.Task.Day04 do
  @moduledoc """
  @see https://adventofcode.com/2015/day/4
  """

  def min_number(src_prefix, ret_prefix) do
    hash_source(src_prefix, ret_prefix, 0)
  end

  def hash_source(src_prefix, ret_prefix, n) do
    hash = md5("#{src_prefix}#{n}")

    if String.starts_with?(hash, ret_prefix) do
      n
    else
      hash_source(src_prefix, ret_prefix, n + 1)
    end
  end

  defp md5(src) do
    :md5
    |> :crypto.hash(src)
    |> Base.encode16()
  end
end
