defmodule Y2019.Day02Test do
  import AOC.Y2019.Day02

  use ExUnit.Case

  describe "run/1" do
    test "it works" do
      assert run_program([1, 0, 0, 0, 99]) == 2
      assert run_program([2, 3, 0, 3, 99]) == 2
      assert run_program([2, 4, 4, 5, 99, 0]) == 2
      assert run_program([1, 1, 1, 4, 99, 5, 6, 0, 99]) == 30
    end
  end
end
