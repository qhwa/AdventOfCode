defmodule Day08Test do
  import AOC.Task.Day08

  use ExUnit.Case, async: true
  doctest AOC.Task.Day08

  test "it works with \\x" do
    assert parse(~S{"\x27"}) == {6, 1}
  end

  test "it works with \\x and \\\\ together" do
    assert parse(~S{"\\x0a"}) == {7, 4}
  end
end
