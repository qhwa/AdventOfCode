defmodule Helper.MyList do
  @moduledoc """
  Some helpers to speed up.
  """

  def qsort([]), do: []

  def qsort([head | tail]) do
    {first, second} = Enum.split_with(tail, &(&1 > head))

    qsort(first) ++ [head | qsort(second)]
  end

  def perms([]), do: [[]]

  def perms(n) when is_integer(n) do
    perms(0..(n - 1) |> Enum.to_list())
  end

  def perms(list) do
    for h <- list, t <- perms(list -- [h]), do: [h | t]
  end

  def pyth(n) do
    for a <- 1..(n - 2),
        b <- (a + 1)..(n - 1),
        c <- (b + 1)..n,
        a + b + c <= n,
        a * a + b * b == c * c do
      {a, b, c}
    end
  end

  def to_map(list) do
    list
    |> Enum.reduce({0, %{}}, fn x, {i, map} -> {i + 1, Map.put(map, i, x)} end)
    |> elem(1)
  end

  @doc """
  Split a list into multiple parts with a pattern of another list.

  ## Example

  iex> split_by([1, 2, 3, 4, 2, 10], [2])
  [[1], [3, 4], [10]]

  iex> split_by([1, 2, 3, 4, 2, 10], [2, 3])
  [[1], [4, 2, 10]]

  iex> split_by([0, 1, 2, 1, 2, 1, 2, 1], [1, 2, 1])
  [[0], [2]]

  iex> split_by([1, 1, 2, 2, 2, 2, 2, 3], [2, 2])
  [[1, 1], [2, 3]]
  """
  def split_by(list, []), do: list

  def split_by(list, pattern) do
    _split_by(list, [], [], pattern, length(pattern))
  end

  defp _split_by([], [], collected, _parts, _size), do: Enum.reverse(collected)

  defp _split_by(list, buffer, collected, parts, size) when length(list) < size do
    buffer = Enum.reverse(list) ++ buffer
    _split_by([], [], collect(collected, buffer), parts, size)
  end

  defp _split_by([head | tail] = list, buffer, collected, pattern, size) do
    if head == hd(pattern) and Enum.take(list, size) == pattern do
      _split_by(Enum.drop(tail, size - 1), [], collect(collected, buffer), pattern, size)
    else
      _split_by(tail, [head | buffer], collected, pattern, size)
    end
  end

  defp collect(collected, []), do: collected
  defp collect(collected, buffer), do: [Enum.reverse(buffer) | collected]
end
