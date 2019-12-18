defmodule Y2019.Day18Test do
  import AOC.Y2019.Day18

  use ExUnit.Case

  describe "turn_routes/2" do
    test "it works with empty routes" do
      assert turn_routes([], :right) == [1, "R"]
      assert turn_routes([], :left) == [1, "L"]
    end

    test "it works with existing routes" do
      assert turn_routes([5, "L"], :right) == [1, "R", 5, "L"]
      assert turn_routes([1, "R"], :left) == [1, "L", 1, "R"]
    end
  end
end
