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
    state = listen(%{map: %{}, pos: {0, 0}, robot: nil})

    print_map(state.map)
    checksum(state.map)
  end

  def p2 do
    Intcode.Computer.start(@program, downstream: self())
    state = listen(%{name: :world, map: %{}, pos: {0, 0}, robot: nil})
    directions = pre_walk(state.map, state.robot)

    monitor =
      spawn(fn ->
        state = listen(%{name: :robot, map: %{}, pos: {0, 0}, robot: nil})
      end)

    @program
    |> Map.put(0, 2)
    |> Intcode.Computer.start(downstream: monitor, input: directions)
  end

  defp listen(%{map: map, pos: pos} = state) do
    receive do
      {:data, 10, _} ->
        {_, y} = pos

        %{state | pos: {0, y + 1}}
        |> listen()

      {:data, data, _} ->
        %{state | map: add_object(map, pos, data), pos: pos + {1, 0}}
        |> on_object(data)
        |> listen()

      {:halt, _} ->
        # IO.inspect(:program_halt, label: inspect(Map.get(state, :name)))
        state

      other ->
        # IO.inspect({:recieve, other})
        listen(state)
    end
  end

  defp on_object(state, data) when data in '^>v<',
    do: %{state | robot: %{pos: state.pos, dir: to_dir(data)}}

  defp on_object(state, ?#), do: state
  defp on_object(state, ?.), do: state

  defp on_object(state, data) do
    # IO.inspect(<<data>>)
    state
  end

  def to_dir(?^), do: {0, -1}
  def to_dir(?<), do: {-1, 0}
  def to_dir(?v), do: {0, 1}
  def to_dir(?>), do: {1, 0}

  defp add_object(map, pos, data), do: Map.put(map, pos, data)

  defp checksum(map) do
    intersection? = fn pos ->
      Map.get(map, pos + {1, 0}) == 35 &&
        Map.get(map, pos + {-1, 0}) == 35 &&
        Map.get(map, pos + {0, 1}) == 35 &&
        Map.get(map, pos + {0, -1}) == 35
    end

    map
    |> key_stops(intersection?)
    |> Stream.map(fn {x, y} -> x * y end)
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

  defp pre_walk(map, robot) do
    pre_walk(map, robot, [])
  end

  defp pre_walk(map, robot, routes) do
    case aheads(map, robot) do
      [_, ?#, _] ->
        routes =
          case routes do
            [n | tail] when is_integer(n) ->
              [n + 1 | tail]

            _ ->
              [1 | routes]
          end

        pre_walk(map, forward(robot), routes)

      [?#, _, _] ->
        pre_walk(map, turn(robot, :left), ["L" | routes])

      [_, _, ?#] ->
        pre_walk(map, turn(robot, :right), ["R" | routes])

      [_, nil, _] ->
        routes
        |> Enum.reverse()
        |> to_directions()
    end
  end

  def aheads(map, %{dir: {dx, dy}, pos: pos} = robot) do
    [
      Map.get(map, pos + {dy, -dx}),
      Map.get(map, pos + {dx, dy}),
      Map.get(map, pos + {-dy, dx})
    ]
  end

  def forward(robot), do: %{robot | pos: robot.pos + robot.dir}

  def turn(%{dir: {dx, dy}} = robot, :left), do: %{robot | dir: {dy, -dx}}
  def turn(%{dir: {dx, dy}} = robot, :right), do: %{robot | dir: {-dy, dx}}

  def neighbours(map, pos) do
    [
      Map.get(map, pos + {1, 0}),
      Map.get(map, pos + {-1, 0}),
      Map.get(map, pos + {0, 1}),
      Map.get(map, pos + {0, -1})
    ]
  end

  defp key_stops(map, checker) do
    map
    |> Stream.filter(fn
      {pos, 35} ->
        checker.(pos)

      {_, _} ->
        false
    end)
    |> Stream.map(fn {pos, _} -> pos end)
  end

  def to_directions(routes) do
    {a, b, c} = find_patterns(routes)

    main_route =
      routes
      |> Enum.join()
      |> String.replace(Enum.join(a), "A")
      |> String.replace(Enum.join(b), "B")
      |> String.replace(Enum.join(c), "C")
      |> String.to_charlist()
      |> Enum.intersperse(?,)

    # function_cmd(a) |> IO.inspect()
    # function_cmd(b) |> IO.inspect()
    # function_cmd(c) |> IO.inspect()

    dirs =
      [main_route, function_cmd(a), function_cmd(b), function_cmd(c)]
      |> Enum.intersperse([?\n])
      |> List.flatten()
      |> Kernel.++([?\n])

    IO.puts(dirs)

    dirs
  end

  def find_patterns(routes) do
    routes =
      routes
      |> Enum.chunk_every(2)
      |> Enum.map(&Enum.join/1)

    all = routes |> Enum.join()

    possibilities =
      for a <- group(routes),
          String.length(Enum.join(a, ",")) <= 20,
          b <- group(routes |> Enum.drop(length(a))),
          String.length(Enum.join(b, ",")) <= 20,
          c <- group(routes |> Enum.drop(length(a) + length(b))),
          String.length(Enum.join(c, ",")) <= 20 do
        {a, b, c}
      end

    possibilities
    |> Enum.find(&(rep_pat(all, &1) == ""))
  end

  def group(routes) do
    1..9 |> Enum.map(&Enum.take(routes, &1))
  end

  def rest(prims, taken) do
    group(prims) -- taken
  end

  def rep_pat(str, {a, b, c}) do
    str
    |> String.replace(a |> Enum.join(), "")
    |> String.replace(b |> Enum.join(), "")
    |> String.replace(c |> Enum.join(), "")
  end

  def function_cmd(a) do
    a |> Enum.join(",") |> String.to_charlist()
  end
end
