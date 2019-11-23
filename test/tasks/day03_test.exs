defmodule Day03Test do
  import AOC.Task.Day03

  use ExUnit.Case

  describe "houses_visit/1" do
    test "it works" do
      assert houses_visit("") == 1
      assert houses_visit(">") == 2
      assert houses_visit("^>v<") == 4
    end
  end
end
