defmodule Day21Test do
  import AOC.Y2015.Day21

  use ExUnit.Case

  describe "win?/2" do
    test "it works" do
      assert win?({8, 5, 5}, {12, 7, 2})
    end
  end
end
