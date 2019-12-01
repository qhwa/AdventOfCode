defmodule Day08Test do
  import AOC.Y2015.Day08

  use ExUnit.Case, async: true
  doctest AOC.Y2015.Day08

  describe "parse/1" do
    test "it works with \\x" do
      assert parse(~S{"\x27"}) == {6, 1}
    end

    test "it works with \\x and \\\\ together" do
      assert parse(~S{"\\x0a"}) == {7, 4}
    end
  end

  describe "parse2/1" do
    test "it works" do
      assert parse2(~S{""}) == {2, 6}
      assert parse2(~S{"abc"}) == {5, 9}
      assert parse2(~S{"aaa\"aaa"}) == {10, 16}
      assert parse2(~S{"\x27"}) == {6, 11}
      assert parse2(~S{"\\x27"}) == {7, 13}
    end
  end
end
