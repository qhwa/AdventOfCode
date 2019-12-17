defmodule AOC.Y2019.Day17 do
  @moduledoc """
  @see https://adventofcode.com/2019/day/17
  """

  import Kernel, except: [+: 2]
  use AOC.Helper.Operator, [:+]
  alias IO.ANSI

  @program Intcode.load_file("priv/data/2019/day17.txt")

  def p1 do
    Intcode.Computer.start(@program, downstream: self())
    state = listen(%{map: %{}, pos: {0, 0}})

    print_map(state.map)
    checksum(state.map)
  end

  def p2 do
    @program
    |> Map.put(0, 2)
    |> Intcode.Computer.start(downstream: self())

    state = listen(%{map: %{}, pos: {0, 0}})

    print_map(state.map)
    checksum(state.map)
  end

  defp listen(%{map: map, pos: pos} = state) do
    receive do
      {:data, 10, _} ->
        {_, y} = pos

        %{state | pos: {0, y + 1}}
        |> listen()

      {:data, data, _} ->
        %{state | map: add_object(map, pos, data), pos: pos + {1, 0}}
        |> listen()

      {:halt, _} ->
        state
    end
  end

  defp add_object(map, pos, data) do
    Map.put(map, pos, data)
  end

  defp checksum(map) do
    intersection? = fn pos ->
      Map.get(map, pos + {1, 0}) == 35 &&
        Map.get(map, pos + {-1, 0}) == 35 &&
        Map.get(map, pos + {0, 1}) == 35 &&
        Map.get(map, pos + {0, -1}) == 35
    end

    map
    |> Stream.filter(fn
      {pos, 35} ->
        intersection?.(pos)

      {_, _} ->
        false
    end)
    |> Stream.map(fn {{x, y}, _} -> x * y end)
    |> Enum.sum()
  end

  defp print_map(map) do
    {min_x, max_x} =
      map
      |> Stream.map(fn {{x, _}, _} -> x end)
      |> Enum.min_max()

    {min_y, max_y} =
      map
      |> Stream.map(fn {{_, y}, _} -> y end)
      |> Enum.min_max()

    for y <- min_y..max_y do
      for x <- min_x..max_x do
        print_tile(Map.get(map, {x, y}), {x, y})
      end
    end
    |> Enum.intersperse([?\r, ?\n])
    |> List.flatten()
    |> IO.puts()
  end

  defp print_tile(nil, _), do: ' '
  defp print_tile(n, _), do: n
end
