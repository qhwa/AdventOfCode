defmodule AOC.Y2019.Day07 do
  @moduledoc """
  @see https://adventofcode.com/2019/day/5
  """

  import Helper.MyList, only: [to_map: 1, perms: 1]

  @program "priv/data/2019/day07.txt"
           |> File.read!()
           |> String.trim()
           |> String.split(",")
           |> Stream.map(&String.to_integer/1)
           |> to_map()

  def p1, do: max_output(@program, perms([0, 1, 2, 3, 4]))
  def p2, do: max_output(@program, perms([5, 6, 7, 8, 9]))

  def max_output(program, sequences) do
    sequences
    |> Stream.map(&final_output(program, &1))
    |> Enum.max()
  end

  def final_output(program, cfgs) do
    cfgs
    |> Enum.with_index()
    |> Enum.map(fn {c, id} ->
      spawn(
        Intcode.Process,
        :init,
        [program, [name: id, parent: self(), input: [c]]]
      )
    end)
    |> start()
    |> listen()
  end

  defp start([head | _] = processes) do
    send(head, {:data, 0})
    processes
  end

  defp listen(processes) do
    receive do
      {:output, data, name} ->
        pipe(processes, name, data)

      _ ->
        listen(processes)
    end
  end

  defp pipe(processes, id, data) do
    pid = upstream(processes, id)

    if Process.alive?(pid) do
      send(pid, {:data, data})
      listen(processes)
    else
      data
    end
  end

  defp upstream(processes, id) do
    processes
    |> Enum.at(rem(id + 1, length(processes)))
  end
end
