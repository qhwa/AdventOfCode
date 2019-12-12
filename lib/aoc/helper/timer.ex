defmodule AOC.Helper.Timer do
  @moduledoc """
  Performance inspect.
  """

  def tc(f) do
    {t, val} = :timer.tc(f)
    IO.puts(["time spent: ", inspect(div(t, 1000)), "ms"])
    val
  end
end
