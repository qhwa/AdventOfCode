defmodule Day19Test do
  import AOC.Task.Day19

  use ExUnit.Case

  @mapping [
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
end
