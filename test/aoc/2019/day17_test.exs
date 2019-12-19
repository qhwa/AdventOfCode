defmodule Y2019.Day17Test do
  import AOC.Y2019.Day17

  use ExUnit.Case

  describe "turn_routes/2" do
    test "it works with empty routes" do
      assert turn_routes([], :right) == [0, "R"]
      assert turn_routes([], :left) == [0, "L"]
    end

    test "it works with existing routes" do
      assert turn_routes([5, "L"], :right) == [0, "R", 5, "L"]
      assert turn_routes([1, "R"], :left) == [0, "L", 1, "R"]
    end
  end

  describe "find_patterns/1" do
    test "it works" do
      routes = ~w[R 1 R 1 R 1 L 2 L 2 L 2 R 4 R 4 R 4 R 1 R 1 R 1 R 4]
      assert find_patterns(routes) == {["R1", "R1", "R1"], ["L2", "L2", "L2"], ["R4"]}

      routes = [
        "R",
        6,
        "R",
        6,
        "R",
        8,
        "L",
        10,
        "L",
        4,
        "R",
        6,
        "L",
        10,
        "R",
        8,
        "R",
        6,
        "L",
        10,
        "R",
        8,
        "R",
        6,
        "R",
        6,
        "R",
        8,
        "L",
        10,
        "L",
        4,
        "L",
        4,
        "L",
        12,
        "R",
        6,
        "L",
        10,
        "R",
        6,
        "R",
        6,
        "R",
        8,
        "L",
        10,
        "L",
        4,
        "L",
        4,
        "L",
        12,
        "R",
        6,
        "L",
        10,
        "R",
        6,
        "R",
        6,
        "R",
        8,
        "L",
        10,
        "L",
        4,
        "L",
        4,
        "L",
        12,
        "R",
        6,
        "L",
        10,
        "R",
        6,
        "L",
        10,
        "R",
        8
      ]

      assert find_patterns(routes) != nil
    end

    test "it works again" do
      routes = ~w[R 8 R 8 R 4 R 4 R 8 L 6 L 2 R 4 R 4 R 8 R 8 R 8 L 6 L 2]
      assert Enum.member?(find_all_patterns(routes), {~w[R8 R8], ~w[R4 R4 R8], ~w[L6 L2]})
    end
  end

  describe "prewalk" do
    test "it works" do
      solutions =
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
        |> GameMap.parse()
        |> pre_walk(%{pos: {0, 6}, dir: {0, -1}})

      assert Enum.all?(solutions, fn sol ->
               Enum.take(sol, 2) in [["R", 8], ["R", 6]]
             end)

      assert Enum.member?(solutions, [
               "R",
               8,
               "R",
               8,
               "R",
               4,
               "R",
               4,
               "R",
               8,
               "L",
               6,
               "L",
               2,
               "R",
               4,
               "R",
               4,
               "R",
               8,
               "R",
               8,
               "R",
               8,
               "L",
               6,
               "L",
               2
             ])
    end
  end
end
