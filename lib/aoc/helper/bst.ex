defmodule Helper.BST do
  @moduledoc """
  Implementation of the BST data structure.
  @see http://pages.cs.wisc.edu/~vernon/cs367/notes/9.BST.html

  A tree or node is represented as a Map:

  %{key: ?a, l: node, r: node}
  """

  @doc """
  Create a new BST from an emunerable.

  ## Example

  """
  def new(key) do
    %{key: key, l: :leaf, r: :leaf}
  end

  def insert(tree, list) when is_list(list), do: Enum.reduce(list, tree, &insert(&2, &1))

  def insert(%{key: key} = node, key), do: node
  def insert(%{key: k, r: :leaf} = node, key) when key > k, do: %{node | r: new(key)}
  def insert(%{key: k, l: :leaf} = node, key) when key < k, do: %{node | l: new(key)}

  def insert(%{key: k, r: r} = node, key) when key > k do
    %{node | r: insert(r, key)}
  end

  def insert(%{key: k, l: l} = node, key) when key < k do
    %{node | l: insert(l, key)}
  end

  @doc """
  Find the minimum value in the tree.
  """
  def min(%{key: key, l: :leaf}), do: key
  def min(%{l: l}), do: min(l)

  @doc """
  Find the maximum value in the tree.
  """
  def max(%{key: key, r: :leaf}), do: key
  def max(%{r: r}), do: max(r)

  def del(%{key: key, l: :leaf, r: :leaf}, key), do: :leaf
  def del(%{key: key, l: :leaf, r: right}, key), do: right
  def del(%{key: key, l: left, r: :leaf}, key), do: left

  def del(%{key: key, l: left, r: right}, key) do
    tmp_key = min(right)
    %{key: tmp_key, l: left, r: del(right, tmp_key)}
  end

  def del(%{key: k, l: :leaf} = node, key) when key < k, do: node
  def del(%{key: k, l: left} = node, key) when key < k, do: %{node | l: del(left, key)}
  def del(%{key: k, r: :leaf} = node, key) when key > k, do: node
  def del(%{key: k, r: right} = node, key) when key > k, do: %{node | r: del(right, key)}
end
