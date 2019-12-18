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
    assert map[{1, 11}] == ?.
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
end
