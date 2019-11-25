defmodule Day07Test do
  import AOC.Task.Day07

  use ExUnit.Case

  describe "parse/1" do
    test "it works" do
      assert parse("123 -> x") == {:x, 123}
      assert parse("456 -> y") == {:y, 456}
      assert parse("x AND y -> d") == {:d, {:and, [:x, :y]}}
      assert parse("x OR y -> e") == {:e, {:or, [:x, :y]}}
      assert parse("x LSHIFT 2 -> f") == {:f, {:"<<", :x, 2}}
      assert parse("y RSHIFT 2 -> g") == {:g, {:">>", :y, 2}}
      assert parse("NOT x -> h") == {:h, {:not, :x}}
      assert parse("la -> xy") == {:xy, :la}
    end

    test "it works with list" do
      assert parse(["123 -> x\n", "246 -> y\n"]) == %{x: 123, y: 246}
    end

    test "it works with mixed types of input" do
      assert parse("123 AND x -> y") == {:y, {:and, [123, :x]}}
    end
  end

  describe "find_value/2" do
    test "it works" do
      circuit = %{
        x: 123,
        y: 456,
        d: {:and, [:x, :y]},
        e: {:or, [:x, :y]},
        f: {:"<<", :x, 2},
        g: {:">>", :y, 2},
        h: {:not, :x},
        i: {:not, :y}
      }

      start_link([])

      assert find_value(circuit, :x) == 123
      assert find_value(circuit, :y) == 456
      assert find_value(circuit, :d) == 72
      assert find_value(circuit, :e) == 507
      assert find_value(circuit, :f) == 492
      assert find_value(circuit, :g) == 114
      assert find_value(circuit, :h) == 65_412
      assert find_value(circuit, :i) == 65_079
    end
  end
end
