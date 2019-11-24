defmodule Day06Test do
  import AOC.Task.Day06

  use ExUnit.Case

  describe "parse_range/1" do
    test "it works" do
      assert parse_range("11,23 to 1,3") == {11, 23, 1, 3}
      assert parse_range("11 23 1 3") == {11, 23, 1, 3}
    end
  end

  describe "parse_instruction/1" do
    test "on" do
      assert parse_instruction("turn on 295,36 through 964,978") == {:on, {295, 36, 964, 978}}
    end

    test "off" do
      assert parse_instruction("turn off 295,36 through 964,978") == {:off, {295, 36, 964, 978}}
    end

    test "toggle" do
      assert parse_instruction("toggle 295,36 through 964,978") == {:toggle, {295, 36, 964, 978}}
    end
  end
end
