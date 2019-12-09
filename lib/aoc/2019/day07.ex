defmodule AOC.Y2019.Day07 do
  @moduledoc """
  @see https://adventofcode.com/2019/day/5
  """

  import Helper.MyList, only: [perms: 1]
  alias Intcode.Computer

  @program Intcode.load_file("priv/data/2019/day07.txt")

  def p1, do: max_output(@program, perms([0, 1, 2, 3, 4]))
  def p2, do: max_output(@program, perms([5, 6, 7, 8, 9]))

  def max_output(program, sequences) do
    sequences
    |> Stream.map(&final_output(program, &1))
    |> Enum.max()
  end

  def final_output(program, [c1, c2, c3, c4, c5]) do
    pid_e = Computer.start(program, downstream: self(), input: [c5])
    pid_d = Computer.start(program, downstream: pid_e, input: [c4])
    pid_c = Computer.start(program, downstream: pid_d, input: [c3])
    pid_b = Computer.start(program, downstream: pid_c, input: [c2])
    pid_a = Computer.start(program, downstream: pid_b, input: [c1, 0])

    Process.monitor(pid_a)
    listen(pid_a, pid_e)
  end

  defp listen(pid_a, pid_e) do
    receive do
      {:data, data, _} when is_nil(pid_a) ->
        data

      {:data, data, _} ->
        send(pid_a, {:data, data, pid_e})
        listen(pid_a, pid_e)

      {:DOWN, _, _, _, _} ->
        listen(nil, pid_e)
    end
  end
end
