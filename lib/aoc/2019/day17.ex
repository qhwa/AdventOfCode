defmodule AOC.Y2019.Day17 do
  @moduledoc """
  @see https://adventofcode.com/2019/day/17
  """

  import Kernel, except: [+: 2]
  use AOC.Helper.Operator, [:+]

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
    print_map(state.map)

    directions =
      pre_walk(state.map, state.robot)
      |> Enum.find(&find_patterns/1)
      |> IO.inspect(label: :good_routes)
      |> to_directions()

    IO.inspect(directions, label: :directions)
    apply_directions(directions)
  end

  defp apply_directions(nil) do
    {:error, nil}
  end

  defp apply_directions(directions) do
    monitor =
      spawn(fn ->
        listen(%{name: :robot, map: %{}, pos: {0, 0}, robot: nil})
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
        %{state | map: add_object(map, pos, data)}
        |> on_object(data)
        |> Map.update!(:pos, &(&1 + {1, 0}))
        |> listen()

      {:halt, _} ->
        # IO.inspect(:program_halt, label: inspect(Map.get(state, :name)))
        state

      other ->
        IO.inspect({:recieve, other})
        listen(state)
    end
  end

  defp on_object(state, data) when data in '^>v<',
    do: %{state | robot: %{pos: state.pos, dir: to_dir(data)}}

  defp on_object(state, ?#), do: state
  defp on_object(state, ?.), do: state

  defp on_object(state, data) do
    IO.puts(<<data>>)
    state
  end

  def to_dir(?^), do: {0, -1}
  def to_dir(?<), do: {-1, 0}
  def to_dir(?v), do: {0, 1}
  def to_dir(?>), do: {1, 0}

  defp add_object(map, pos, data), do: Map.put(map, pos, data)

  defp checksum(map) do
    map
    |> key_stops(&intersection?/2)
    |> Stream.map(fn {x, y} -> x * y end)
    |> Enum.sum()
  end

  def intersection?(pos, map) do
    Map.get(map, pos + {1, 0}) == 35 &&
      Map.get(map, pos + {-1, 0}) == 35 &&
      Map.get(map, pos + {0, 1}) == 35 &&
      Map.get(map, pos + {0, -1}) == 35
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

  def parse_map(src) do
    src
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      line
      |> String.to_charlist()
      |> Enum.with_index()
      |> Enum.map(fn {char, x} ->
        {{x, y}, char}
      end)
    end)
    |> Enum.into(%{})
  end

  def pre_walk(map, robot) do
    grids =
      map
      |> key_stops()
      |> Enum.to_list()
      |> Kernel.++(key_stops(map, &intersection?/2) |> Enum.to_list())

    pre_walk(map, robot, [], grids)
    |> Stream.filter(fn
      {:dead, _} -> false
      {:ok, _} -> true
    end)
    |> Stream.map(fn {:ok, routes} -> routes end)
    |> Enum.to_list()
  end

  defp pre_walk(_map, _robot, routes, []) do
    {:ok, routes |> Enum.reverse()}
  end

  defp pre_walk(map, %{pos: pos} = robot, routes, remain) do
    case aheads(map, robot, remain) do
      [nil, ?#, nil] ->
        [forward(map, robot, routes, remain)]

      [?#, ?#, ?#] ->
        [
          forward(map, robot, routes, remain),
          turn_left(map, robot, routes, remain),
          turn_right(map, robot, routes, remain)
        ]

      [?#, nil, nil] ->
        [turn_left(map, robot, routes, remain)]

      [nil, nil, ?#] ->
        [turn_right(map, robot, routes, remain)]

      [nil, nil, nil] ->
        case remain do
          [^pos] ->
            [{:ok, Enum.reverse(routes)}]

          _ ->
            [{:dead, length(remain)}]
        end
    end
    |> List.flatten()
  end

  def forward(map, robot, routes, remain) do
    pre_walk(
      map,
      forward_robot(robot),
      forward_routes(routes),
      remain -- [robot.pos]
    )
  end

  def turn_left(map, %{pos: pos} = robot, routes, remain) do
    robot = turn(robot, :left) |> forward_robot()

    pre_walk(
      map,
      robot,
      forward_routes(turn_routes(routes, :left)),
      remain -- [pos, robot.pos]
    )
  end

  def turn_right(map, %{pos: pos} = robot, routes, remain) do
    robot = turn(robot, :right) |> forward_robot()

    pre_walk(
      map,
      robot,
      forward_routes(turn_routes(routes, :right)),
      remain -- [pos, robot.pos]
    )
  end

  def forward_robot(%{pos: pos, dir: dir} = robot) do
    %{robot | pos: pos + dir}
  end

  def forward_routes(routes) do
    case routes do
      [] ->
        []

      [n | tail] when is_integer(n) ->
        [n + 1 | tail]
    end
  end

  def aheads(map, %{dir: {dx, dy}, pos: pos}, remain) do
    [
      pos + {dy, -dx},
      pos + {dx, dy},
      pos + {-dy, dx}
    ]
    |> Enum.map(fn pos ->
      if Enum.member?(remain, pos) do
        case Map.get(map, pos) do
          ?# -> ?#
          _ -> nil
        end
      else
        nil
      end
    end)
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

  defp key_stops(map, checker \\ fn _, _ -> true end) do
    map
    |> Stream.filter(fn
      {pos, 35} ->
        checker.(pos, map)

      {_, _} ->
        false
    end)
    |> Stream.map(fn {pos, _} -> pos end)
  end

  def to_directions(nil) do
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
          b <- group(routes |> Enum.drop(length(a))),
          c <- group(routes |> Enum.drop(length(a) + length(b))) do
        {a, b, c}
      end

    possibilities
    |> Enum.find(&(rep_pat(all, &1) == ""))
  end

  def find_all_patterns(routes) do
    routes =
      routes
      |> Enum.chunk_every(2)
      |> Enum.map(&Enum.join/1)

    all = routes |> Enum.join()

    possibilities =
      for a <- group(routes),
          b <- group(routes |> Enum.drop(length(a))),
          c <- group(routes |> Enum.drop(length(a) + length(b))) do
        {a, b, c}
      end

    possibilities
    |> Enum.filter(&(rep_pat(all, &1) == ""))
  end

  def group(routes) do
    1..7
    |> Enum.map(&Enum.take(routes, &1))
    |> Enum.filter(&(String.length(Enum.join(&1, ",")) <= 20))
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

  def turn_routes(routes, :left), do: [0, "L" | routes]
  def turn_routes(routes, :right), do: [0, "R" | routes]
end
