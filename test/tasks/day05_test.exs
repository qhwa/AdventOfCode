defmodule Day05Test do
  import AOC.Task.Day05

  use ExUnit.Case

  describe "part1_nice?/1" do
    test "it works" do
      assert part1_nice?("ugknbfddgicrmopn")
      assert part1_nice?("aaa")
      refute part1_nice?("jchzalrnumimnmhp")
      refute part1_nice?("haegwjzuvuyypxyu")
      refute part1_nice?("dvszwmarrgswjxmb")
    end
  end

  describe "nice?/1" do
    test "it works" do
      assert nice?("qjhvhtzxzqqjkmpb")
      assert nice?("xxyxx")
      refute nice?("aaa")
      refute nice?("uurcxstgmygtbstg")
      refute nice?("ieodomkazucvgmuy")
    end
  end
end
