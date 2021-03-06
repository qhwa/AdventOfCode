defmodule AOC.Y2019.Day11 do
  @moduledoc """
  @see http://adventofcode.com/2019/day/11
  """

  def p1, do: run_program([]) |> Map.get(:pannels) |> Enum.count()

  def p2, do: run_program(pannels: %{{0, 0} => 1}) |> print()

  defp run_program(opts) do
    pid =
      load_program()
      |> Intcode.Computer.start(downstream: self())

    opts
    |> init()
    |> work(pid)
  end

  defp load_program, do: Intcode.load_file("priv/data/2019/day11.txt")

  defp init(opts), do: Enum.into(opts, %{pannels: %{}, pos: {0, 0}, dir: [0, -1]})

  defp work(map, pid) do
    report_current_color(map, pid)

    with {:ok, color} <- read(),
         {:ok, move} <- read() do
      map
      |> paint_pannel(color)
      |> turn_and_move(move)
      |> work(pid)
    else
      {:halt, _} ->
        map
    end
  end

  defp report_current_color(map, pid) do
    send(pid, {:data, Map.get(map.pannels, map.pos, 0), self()})
  end

  defp read do
    receive do
      {:data, color, _} -> {:ok, color}
      other -> other
    end
  end

  defp paint_pannel(map, color) do
    Map.update!(map, :pannels, &Map.put(&1, map.pos, color))
  end

  defp turn_and_move(map, move) do
    map
    |> Map.update!(:dir, &turn(&1, move))
    |> move_forward()
  end

  @doc """
  @see https://matthew-brett.github.io/teaching/rotation_2d.html#theorem
  """
  def turn([x, y], 0), do: [y, -x]
  def turn([x, y], 1), do: [-y, x]

  defp move_forward(%{pos: {x, y}, dir: [dx, dy]} = map) do
    Map.put(map, :pos, {x + dx, y + dy})
  end

  defp print(%{pannels: pannels}) do
    {min_x, max_x} =
      pannels
      |> Stream.map(fn {{x, _}, _} -> x end)
      |> Enum.min_max()

    {min_y, max_y} =
      pannels
      |> Stream.map(fn {{_, y}, _} -> y end)
      |> Enum.min_max()

    for y <- min_y..max_y do
      for x <- min_x..max_x do
        case Map.get(pannels, {x, y}, 0) do
          0 -> ' '
          1 -> ?#
        end
      end
    end
    |> Enum.intersperse(?\n)
    |> IO.puts()
  end
end
