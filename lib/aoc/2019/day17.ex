defmodule AOC.Y2019.Day17 do
  @moduledoc """
  @see https://adventofcode.com/2019/day/17
  """

  import Kernel, except: [+: 2]
  use AOC.Helper.Operator, [:+]

  @program Intcode.load_file("priv/data/2019/day17.txt")

  def p1 do
    read_map() |> p1_checksum()
  end

  defp read_map() do
    @program
    |> Intcode.Computer.function_mode()
    |> GameMap.load()
  end

  def p2 do
    map = read_map()

    directions =
      pre_walk(map, %{pos: GameMap.locate(map, ?^), dir: {0, -1}})
      |> Enum.find(&find_patterns/1)
      |> to_directions()

    apply_directions(directions)
  end

  def p2_manually do
    'A,B,B,A,C,A,C,A,C,B\nR,6,R,6,R,8,L,10,L,4\nR,6,L,10,R,8\nL,4,L,12,R,6,L,10\nn\n'
    |> apply_directions()
    |> Enum.take(-1)
  end

  defp apply_directions(nil) do
    {:error, nil}
  end

  defp apply_directions(directions) do
    @program
    |> Map.put(0, 2)
    |> Intcode.Computer.function_mode(input: directions)
  end

  defp p1_checksum(map) do
    map
    |> GameMap.intersections()
    |> Stream.map(fn {x, y} -> x * y end)
    |> Enum.sum()
  end

  def intersection?(pos, map) do
    Map.get(map, pos + {1, 0}) == 35 &&
      Map.get(map, pos + {-1, 0}) == 35 &&
      Map.get(map, pos + {0, 1}) == 35 &&
      Map.get(map, pos + {0, -1}) == 35
  end

  def pre_walk(map, robot) do
    grids =
      map
      |> GameMap.intersections()

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
