defmodule GameMapTest do
  use ExUnit.Case

  setup do
    map =
      """
      #######...#####
      #.....#...#...#
      #.....#...#...#
      ......#...#...#
      ......#...###.#
      ......#.....#.#
      ^########...#.#
      ......#.#...#.#
      ......#########
      ........#...#..
      ....#########..
      ....#...#......
      ....#...#......
      ....#...#......
      ....#####......
      """
      |> GameMap.load()

    {:ok, %{map: map}}
  end

  test "load/1", %{map: map} do
    assert %{{0, 0} => ?#} = map
    assert map[{8, 11}] == ?#
    assert map[{1, 11}] == nil
    assert map[{0, 6}] == ?^
  end

  test "max_x/1, and max_y/2", %{map: map} do
    assert GameMap.max_x(map) == 14
    assert GameMap.max_y(map) == 14
  end

  test "print/1", %{map: map} do
    assert :ok = GameMap.print(map)
  end

  test "locate/2", %{map: map} do
    assert {0, 6} == GameMap.locate(map, ?^)
  end

  test "locations/1", %{map: map} do
    locations = GameMap.locations(map)
    assert length(locations) == 77
  end

  test "locations/1 works with customer locater", %{map: map} do
    locations =
      GameMap.locations(map, fn {x, y}, map ->
        map[{x, y}] == ?# and
          x == 0 and
          map[{x + 1, y}] == nil and
          map[{x, y + 1}] == nil
      end)

    assert locations == [{0, 2}]
  end

  test "locations/1 works with customer check function of arity 1", %{map: map} do
    locations = GameMap.locations(map, fn {x, y} -> x == y end)
    assert Enum.sort(locations) == [{0, 0}, {6, 6}, {8, 8}, {10, 10}]
  end

  test "locations/1 works with customer check function of arity 3", %{map: map} do
    locations = GameMap.locations(map, fn _pos, v, _map -> v != ?# end)
    assert locations == [{0, 6}]
  end

  test "intersections/1", %{map: map} do
    inters = GameMap.intersections(map)
    assert Enum.sort(inters) == [{6, 6}, {8, 8}, {8, 10}, {12, 8}]
  end
end
