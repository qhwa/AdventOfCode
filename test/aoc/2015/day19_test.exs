defmodule Day19Test do
  import AOC.Y2015.Day19

  use ExUnit.Case

  @mapping [
    {"e", "H"},
    {"e", "O"},
    {"H", "HO"},
    {"H", "OH"},
    {"O", "HH"},
    {"Na", "OH"}
  ]

  describe "group_count/2" do
    test "it works" do
      assert group_count("HOH", @mapping) == 4
      assert group_count("HOHOHO", @mapping) == 7
    end

    test "it works with 2 letter atoms" do
      assert group_count("NaNa", @mapping) == 2
    end
  end

  describe "step/2" do
    test "it works" do
      assert step("HOH", @mapping) == 3
      assert step("HOHOHO", @mapping) == 6
    end
  end
end
