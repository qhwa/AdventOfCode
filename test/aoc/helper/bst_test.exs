defmodule BstTest do
  import Helper.BST

  use ExUnit.Case

  setup do
    {:ok, %{tree: build_tree()}}
  end

  describe "min/1" do
    test "it works", %{tree: tree} do
      assert min(tree) > 0
      assert min(tree) < 100

      tree = tree |> insert(-1)
      assert min(tree) == -1
    end
  end

  describe "max/1" do
    test "it works", %{tree: tree} do
      assert max(tree) > 0
      assert max(tree) < 100

      tree = tree |> insert(101)
      assert max(tree) == 101
    end
  end

  describe "del/1" do
    test "it works when deleting leaf nodes" do
      assert del(%{key: 0, l: :leaf, r: :leaf}, 0) == :leaf
    end

    test "it works when target is not in the tree", %{tree: tree} do
      assert del(tree, -1) == tree
    end

    test "it works when target is in the tree", %{tree: tree} do
      m = min(tree)
      assert tree |> del(m) |> min() > m
    end

    test "it works when deleting a node with exactly one child" do
      tree =
        5
        |> new()
        |> insert([1, 34, 42, 13, 7, 50])

      assert del(tree, 13) == %{
               key: 5,
               l: %{key: 1, l: :leaf, r: :leaf},
               r: %{
                 key: 34,
                 l: %{key: 7, l: :leaf, r: :leaf},
                 r: %{key: 42, l: :leaf, r: %{key: 50, l: :leaf, r: :leaf}}
               }
             }
    end
  end

  defp build_tree() do
    fn -> :rand.uniform(100) end
    |> Stream.repeatedly()
    |> Stream.take(5)
    |> Enum.reduce(new(50), &insert(&2, &1))
  end
end
