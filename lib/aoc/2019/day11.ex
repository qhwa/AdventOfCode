defmodule AOC.Y2019.Day11 do
  @moduledoc """
  @see http://adventofcode.com/2019/day/11
  """

  def p1 do
    program = Intcode.load_file("priv/data/2019/day11.txt")
    pid = Intcode.Computer.start(program, downstream: self())

    paint_identifier(%{pannels: %{}, pos: {0, 0}, dir: [0, -1]}, pid)
    |> Map.get(:pannels)
    |> Enum.count()
  end

  def p2 do
  end

  defp paint_identifier(map, pid) do
    report_current_color(map, pid)

    with {:ok, color} <- fetch_color_instruct(),
         {:ok, move} <- fetch_move_instruct() do
      map
      |> paint_pannel(color)
      |> turn_and_move(move)
      |> paint_identifier(pid)
    else
      {:halt, _} ->
        map
    end
  end

  defp report_current_color(map, pid) do
    send(pid, {:data, Map.get(map.pannels, map.pos, 0), self()})
  end

  defp fetch_color_instruct do
    receive do
      {:data, color, _} -> {:ok, color}
      other -> other
    end
  end

  defp fetch_move_instruct do
    receive do
      {:data, move, _} -> {:ok, move}
      other -> other
    end
  end

  defp paint_pannel(map, color) do
    map
    |> Map.update!(:pannels, &Map.put(&1, map.pos, color))
  end

  defp turn_and_move(map, move) do
    map
    |> Map.update!(:dir, &turn(&1, move))
    |> move_forward()
  end

  defp turn([0, -1], 0), do: [-1, 0]
  defp turn([-1, 0], 0), do: [0, 1]
  defp turn([0, 1], 0), do: [1, 0]
  defp turn([1, 0], 0), do: [0, -1]

  defp turn([0, -1], 1), do: [1, 0]
  defp turn([1, 0], 1), do: [0, 1]
  defp turn([0, 1], 1), do: [-1, 0]
  defp turn([-1, 0], 1), do: [0, -1]

  defp move_forward(%{pos: {x, y}, dir: [dx, dy]} = map) do
    map
    |> Map.put(:pos, {x + dx, y + dy})
  end
end
