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

  describe "houses_visit_with_robot/1" do
    test "it works" do
      assert houses_visit_with_robot("") == 1
      assert houses_visit_with_robot(">") == 2
      assert houses_visit_with_robot("^^") == 2
      assert houses_visit_with_robot("^v") == 3
      assert houses_visit_with_robot("^>v<") == 3
      assert houses_visit_with_robot("^v^v^v^v^v") == 11
    end
  end
end
