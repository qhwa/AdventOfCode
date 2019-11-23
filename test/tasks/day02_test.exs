defmodule Day02Test do
  import AOC.Task.Day02

  use ExUnit.Case

  test "it works with single tuple" do
    assert resolve({2, 3, 4}) == 58
    assert resolve({1, 1, 10}) == 43
  end

  test "it works with lists" do
    assert resolve([{2, 3, 4}, {1, 1, 10}]) == 58 + 43
  end

  test "it works single entry in binary" do
    assert resolve("2x3x4") == 58
  end

  test "it works file stream" do
    assert resolve({:file, "test/fixtures/day02.txt"}) == 5259
  end
end
