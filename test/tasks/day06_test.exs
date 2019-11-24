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

  describe "operate/2" do
    test "it works with invalid instruction" do
      lights = [[0, 0], [0, 0]]
      assert operate("whatever", lights) == lights
    end

    test "it works with `on` instruction" do
      lights = {2, init_lights(2)}
      assert operate({:on, {0, 0, 1, 1}}, lights) == {2, [1, 1, 1, 1]}
    end

    test "it works with `off` instruction" do
      lights = {2, [0, 0, 1, 0]}
      assert operate({:off, {0, 0, 1, 1}}, lights) == {2, [0, 0, 0, 0]}
    end

    test "it works with `toggle` instruction" do
      lights = {3, [0, 0, 1, 0, 1, 0, 1, 1, 1]}
      assert operate({:toggle, {0, 0, 1, 1}}, lights) == {3, [1, 1, 1, 1, 0, 0, 1, 1, 1]}
    end

    test "it works with `on` instruction in binary format" do
      lights = {2, [0, 0, 0, 0]}
      assert operate("turn on 0,0 through 1,1", lights) == {2, [1, 1, 1, 1]}
    end
  end
end
