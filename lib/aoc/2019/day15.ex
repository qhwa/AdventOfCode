defmodule AOC.Y2019.Day15 do
  @moduledoc """
  @see https://adventofcode.com/2019/day/15
  """

  import Kernel, except: [+: 2]
  use AOC.Helper.Operator, [:+]
  alias IO.ANSI

  @program Intcode.load_file("priv/data/2019/day15.txt")

  def p1 do
    [map1, map2] =
      [
        Task.async(fn -> solve_with_strategy(:left_side_first) end),
        Task.async(fn -> solve_with_strategy(:right_side_first) end)
      ]
      |> Enum.map(&Task.await/1)

    cmap = common_path(map1, map2)

    map1
    |> Map.merge(map2)
    |> Map.merge(cmap)
    |> print_map()

    cmap |> Enum.count() |> Kernel.+(1)
  end

  def p2 do
    [map1, map2] =
      [
        Task.async(fn -> solve_with_strategy(:left_side_first) end),
        Task.async(fn -> solve_with_strategy(:right_side_first) end)
      ]
      |> Enum.map(&Task.await/1)

    ox_spot =
      map1
      |> Enum.find(fn {_, v} -> v == 2 end)
      |> elem(0)

    empty_tiles =
      [map1, map2]
      |> Enum.map(&to_path/1)
      |> Enum.reduce(&MapSet.union/2)
      |> MapSet.to_list()

    spread(empty_tiles, MapSet.new([ox_spot]))
  end

  defp solve_with_strategy(strategy) do
    pid =
      @program
      |> Intcode.Computer.start(downstream: self())

    %{map: map} = listen(%{map: %{}, pos: {0, 0}, dir: {1, 0}, strategy: strategy, game: pid})
    Process.exit(pid, :normal)
    map
  end

  defp listen(state) do
    move(state)

    receive do
      {:data, 0, _} ->
        state
        |> on_wall()
        |> listen()

      {:data, 1, _} ->
        state
        |> on_move()
        |> listen()

      {:data, 2, _} ->
        state
        |> found()
    end
  end

  defp move(%{dir: {0, -1}, game: game}), do: send(game, {:data, 1, self()})
  defp move(%{dir: {0, 1}, game: game}), do: send(game, {:data, 2, self()})
  defp move(%{dir: {-1, 0}, game: game}), do: send(game, {:data, 3, self()})
  defp move(%{dir: {1, 0}, game: game}), do: send(game, {:data, 4, self()})

  defp on_wall(state) do
    state
    |> remember(1)
    |> turn_90_deg()
  end

  defp remember(%{pos: pos, dir: dir} = state, value) do
    state
    |> Map.update!(:map, &Map.put_new(&1, pos + dir, value))
  end

  defp turn_90_deg(%{dir: dir, pos: pos, map: map} = state) do
    t =
      if state.strategy == :left_side_first do
        {-1, 1}
      else
        {1, -1}
      end

    %{state | dir: next_available_dir(dir, pos, map, t)}
  end

  defp next_available_dir({dx, dy}, {x, y}, map, t) do
    case Map.get(map, {dx, dy} + {x, y}) do
      nil ->
        {dx, dy}

      0 ->
        {dx, dy}

      1 ->
        {tx, ty} = t
        next_available_dir({tx * dy, ty * dx}, {x, y}, map, t)
    end
  end

  defp on_move(state) do
    state
    |> remember(0)
    |> forward()
    |> look_by_strategy()
  end

  defp forward(%{dir: dir, pos: pos} = state) do
    %{state | pos: pos + dir}
  end

  defp look_by_strategy(%{strategy: :left_side_first} = state) do
    try_turn_if_possible(state, [1, -1])
  end

  defp look_by_strategy(%{strategy: :right_side_first} = state) do
    try_turn_if_possible(state, [-1, 1])
  end

  defp try_turn_if_possible(%{dir: {dx, dy}, pos: pos, map: map} = state, [tx, ty]) do
    strategy_dir = {dy * tx, dx * ty}
    look_at = strategy_dir + pos

    case map do
      %{^look_at => 1} ->
        state

      _ ->
        %{state | dir: strategy_dir}
    end
  end

  defp found(state) do
    state |> remember(2)
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

  defp print_tile(_, {0, 0}), do: [ANSI.cyan(), ?X, ANSI.reset()]
  defp print_tile(nil, _), do: ' '
  defp print_tile(0, _), do: '.'
  defp print_tile(1, _), do: '#'
  defp print_tile(2, _), do: [ANSI.cyan(), ?O, ANSI.reset()]
  defp print_tile(3, _), do: [ANSI.red(), ?*, ANSI.reset()]

  defp common_path(map1, map2) do
    path1 = map1 |> to_path()
    path2 = map2 |> to_path()

    MapSet.intersection(path1, path2)
    |> Stream.map(fn k -> {k, 3} end)
    |> Map.new()
  end

  defp to_path(map) do
    map
    |> Stream.filter(fn {_, v} -> v == 0 end)
    |> Stream.map(fn {k, _} -> k end)
    |> MapSet.new()
  end

  defp spread(unvisited, visited, step \\ 0)

  defp spread([], _, step), do: step

  defp spread(unvisited, visited, step) do
    spreaded =
      visited
      |> Enum.flat_map(fn tile ->
        Enum.filter(unvisited, &(distance(&1, tile) == 1))
      end)

    spread(unvisited -- spreaded, spreaded, step + 1)
  end

  defp distance({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end
end
