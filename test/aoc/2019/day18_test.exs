defmodule Y2019.Day18Test do
  import AOC.Y2019.Day18

  use ExUnit.Case

  describe "shortest_steps/1" do
    test "it works for the simplest example" do
      map =
        """
        #########
        #b.A.@.a#
        #########
        """
        |> GameMap.parse()

      assert shortest_path(map) == [
               {5, 1},
               {6, 1},
               {7, 1},
               {6, 1},
               {5, 1},
               {4, 1},
               {3, 1},
               {2, 1},
               {1, 1}
             ]
    end
  end

  describe "open_neighbors/2" do
    test "it works" do
      map =
        """
        #########
        #b.A.@.a#
        #########
        """
        |> GameMap.parse()

      assert open_neighbors(map, {5, 1}) == [{4, 1}, {6, 1}]
      assert open_neighbors(map, {4, 1}) == [{5, 1}]
    end
  end
end
