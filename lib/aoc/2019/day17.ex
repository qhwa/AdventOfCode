defmodule AOC.Y2019.Day17 do
  @moduledoc """
  @see https://adventofcode.com/2019/day/17
  """

  import Kernel, except: [+: 2]
  import Helper.MyList, only: [split_by: 2, perms: 1]

  use AOC.Helper.Operator, [:+]

  @program Intcode.load_file("priv/data/2019/day17.txt")

  def p1 do
    read_map() |> p1_checksum()
  end

  defp read_map() do
    @program
    |> Intcode.Computer.function_mode()
    |> GameMap.parse()
  end

  def p2 do
    map = read_map()

    directions =
      pre_walk(map, %{pos: GameMap.locate(map, ?^), dir: {0, -1}})
      |> Enum.find(&find_patterns/1)
      |> to_directions()

    @program
    |> Map.put(0, 2)
    |> Intcode.Computer.function_mode(input: directions)
    |> Enum.take(-1)
  end

  defp p1_checksum(map) do
    map
    |> GameMap.intersections()
    |> Stream.map(fn {x, y} -> x * y end)
    |> Enum.sum()
  end

  def pre_walk(map, robot) do
    grids =
      map
      |> GameMap.locations(fn _, v, _ -> v == ?# end)
      |> Kernel.++(GameMap.intersections(map))

    map
    |> pre_walk(robot, [], grids)
    |> Stream.filter(fn
      {:ok, _} -> true
      _ -> false
    end)
    |> Enum.map(fn {_, routes} -> routes end)
  end

  defp pre_walk(_map, _robot, routes, []) do
    {:ok, routes |> Enum.reverse()}
  end

  defp pre_walk(map, %{pos: pos} = robot, routes, remain) do
    forward = fn ->
      pre_walk(
        map,
        forward_robot(robot),
        forward_routes(routes),
        remain -- [robot.pos]
      )
    end

    turn_lr = fn dir ->
      robot = turn(robot, dir) |> forward_robot()

      pre_walk(
        map,
        robot,
        forward_routes(turn_routes(routes, dir)),
        remain -- [pos, robot.pos]
      )
    end

    case aheads(map, robot, remain) do
      [_, ?#, _] ->
        [forward.()]

      [?#, _, _] ->
        [turn_lr.(:left)]

      [_, _, ?#] ->
        [turn_lr.(:right)]

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

    [main_route, function_cmd(a), function_cmd(b), function_cmd(c)]
    |> Enum.intersperse([?\n])
    |> List.flatten()
    |> Kernel.++([?\n, ?n, ?\n])
  end

  def find_patterns(routes) do
    routes =
      routes
      |> Enum.chunk_every(2)
      |> Enum.map(&Enum.join/1)

    routes
    |> pattern_perms()
    |> Enum.find(&working_patten?(routes, &1))
  end

  defp pattern_perms(routes) do
    for a <- group(routes),
        after_a = apply_pattern(routes, a),
        b <- group(after_a),
        nil not in b,
        after_b = apply_pattern(after_a, b),
        c <- group(after_b),
        nil not in c do
      {a, b, c}
    end
  end

  def group(routes) do
    1..7
    |> Enum.map(&Enum.take(routes, &1))
    |> Enum.filter(&(String.length(Enum.join(&1, ",")) <= 20))
  end

  def apply_pattern(routes, pattern) do
    split_by(routes, pattern)
    |> Enum.intersperse([nil])
    |> List.flatten()
    |> Enum.drop_while(&is_nil/1)
  end

  def working_patten?(routes, {a, b, c}) do
    perms([a, b, c])
    |> Enum.any?(&_working_patten?(routes, &1))
  end

  def _working_patten?(routes, patterns) do
    patterns
    |> Enum.reduce(routes, fn p, acc ->
      acc
      |> split_by(p)
      |> Enum.intersperse(nil)
      |> List.flatten()
    end)
    |> Enum.all?(&is_nil/1)
  end

  def function_cmd(a) do
    a
    |> Enum.map(fn <<dir::binary-size(1), len::binary>> -> [dir, len] end)
    |> List.flatten()
    |> Enum.join(",")
    |> String.to_charlist()
  end

  def turn_routes(routes, :left), do: [0, "L" | routes]
  def turn_routes(routes, :right), do: [0, "R" | routes]
end
