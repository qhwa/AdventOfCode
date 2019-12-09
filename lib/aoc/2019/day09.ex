defmodule AOC.Y2019.Day09 do
  @moduledoc """
  @see http://adventofcode.com/2019/day/9
  """

  alias Intcode.Computer

  @program Intcode.load_file("priv/data/2019/day09.txt")

  def p1 do
    Computer.start(@program, input: [1], downstream: self())

    listen()
  end

  def p2 do
    {t, _} =
      :timer.tc(fn ->
        Computer.start(@program, input: [2], downstream: self())
        listen()
      end)

    IO.puts(["time spent: ", inspect(div(t, 1000)), "ms"])
  end

  defp listen() do
    receive do
      {:data, data, _} ->
        IO.puts(["-> ", inspect(data)])
        listen()

      {:halt, _} ->
        :ok
    end
  end
end
