defmodule Day02Test do
  import AOC.Y2015.Day02

  use ExUnit.Case

  describe "feet_of_wrapping_paper/1" do
    test "it works with single tuple" do
      assert feet_of_wrapping_paper({2, 3, 4}) == 58
      assert feet_of_wrapping_paper({1, 1, 10}) == 43
    end

    test "it works with lists" do
      assert feet_of_wrapping_paper([{2, 3, 4}, {1, 1, 10}]) == 58 + 43
    end

    test "it works with single entry in binary" do
      assert feet_of_wrapping_paper("2x3x4") == 58
    end

    test "it works with file stream" do
      assert feet_of_wrapping_paper({:file, "test/fixtures/day02.txt"}) == 5259
    end
  end

  describe "feet_of_ribbon/1" do
    test "it works" do
      assert feet_of_ribbon({2, 3, 4}) == 34
      assert feet_of_ribbon([{2, 3, 4}, {1, 1, 10}]) == 48
    end

    test "it works with file stream" do
      assert feet_of_ribbon({:file, "test/fixtures/day02.txt"}) == 12_714
    end
  end
end
