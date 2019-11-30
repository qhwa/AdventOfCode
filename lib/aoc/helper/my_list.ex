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
end
