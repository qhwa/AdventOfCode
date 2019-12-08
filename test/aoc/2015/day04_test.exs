defmodule Day04Test do
  import AOC.Y2015.Day04

  use ExUnit.Case

  describe "min_number/1" do
    test "it works" do
      assert min_number("abcdef", "00000") == 609_043
      assert min_number("pqrstuv", "00000") == 1_048_970
    end
  end
end
