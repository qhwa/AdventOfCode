defmodule AOC.Y2019.Day13 do
  @moduledoc """
  @see http://adventofcode.com/2019/day/13
  """

  def p1, do: load_program() |> draw_tiles() |> count()
  def p2, do: nil

  defp load_program do
    "priv/data/2019/day13.txt"
    |> Intcode.load_file()
  end

  defp draw_tiles(program) do
    Intcode.Computer.start(program, downstream: self())

    listen(%{})
  end

  defp listen(state) do
    with {:ok, x} <- read(),
         {:ok, y} <- read(),
         {:ok, tile_id} <- read() do
      draw(state, {x, y}, tile_id)
      |> listen()
    else
      {:halt, _} ->
        state
    end
  end

  defp read do
    receive do
      {:data, data, _} ->
        {:ok, data}

      other ->
        other
    end
  end

  defp draw(state, pos, tile_id) do
    Map.put(state, pos, tile_id)
  end

  defp count(state) do
    Enum.reduce(state, 0, fn
      {_, 2}, acc -> acc + 1
      _, acc -> acc
    end)
  end
end
