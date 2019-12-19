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

  describe "working_patten?/2" do
    test "it works" do
      routes = [
        "R6",
        "R6",
        "R8",
        "L10",
        "L4",
        "R6",
        "L10",
        "R8",
        "R6",
        "L10",
        "R8",
        "R6",
        "R6",
        "R8",
        "L10",
        "L4",
        "L4",
        "L12",
        "R6",
        "L10",
        "R6",
        "R6",
        "R8",
        "L10",
        "L4",
        "L4",
        "L12",
        "R6",
        "L10",
        "R6",
        "R6",
        "R8",
        "L10",
        "L4",
        "L4",
        "L12",
        "R6",
        "L10",
        "R6",
        "L10",
        "R8"
      ]

      assert working_patten?(
               routes,
               {["R6", "R6", "R8", "L10", "L4"], ["R6", "L10", "R8"], ["L4", "L12", "R6", "L10"]}
             )
    end

    test "it works again" do
      routes = ~w[R8 R8 R4 R4 R8 L6 L2 R4 R4 R8 R8 R8 L6 L2]
      assert working_patten?(routes, {~w[R8 R8], ~w[R4 R4 R8], ~w[L6 L2]})
    end
  end
end
