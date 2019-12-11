defmodule Y2019.Day11Test do
  import AOC.Y2019.Day11

  use ExUnit.Case

  describe "turn/2" do
    test "it works" do
      assert turn([0, -1], 0) == [-1, 0]
      assert turn([-1, 0], 0) == [0, 1]
      assert turn([0, 1], 0) == [1, 0]
      assert turn([1, 0], 0) == [0, -1]

      assert turn([0, -1], 1) == [1, 0]
      assert turn([1, 0], 1) == [0, 1]
      assert turn([0, 1], 1) == [-1, 0]
      assert turn([-1, 0], 1) == [0, -1]
    end
  end
end
