defmodule AOC do
  @moduledoc """
  This module defines the common behaviour of every solution's structure.
  """

  @callback setup() :: {:ok, term}
  @callback p1(term) :: term
  @callback p2(term) :: term
end
