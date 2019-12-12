defmodule AOC.Y2019.Day12 do
  @moduledoc """
  @see http://adventofcode.com/2019/day/12
  """

  @moons [
    %{pos: {-19, -4, 2}, vel: {0, 0, 0}},
    %{pos: {-9, 8, -16}, vel: {0, 0, 0}},
    %{pos: {-4, 5, -11}, vel: {0, 0, 0}},
    %{pos: {1, 9, -13}, vel: {0, 0, 0}}
  ]

  def p1, do: simulate(@moons, 1000) |> to_energy()

  def p2, do: :ok

  def example do
    [
      %{pos: {-8, -10, 0}, vel: {0, 0, 0}},
      %{pos: {5, 5, 10}, vel: {0, 0, 0}},
      %{pos: {2, -7, 3}, vel: {0, 0, 0}},
      %{pos: {9, -8, -3}, vel: {0, 0, 0}}
    ]
    |> simulate(100)
  end

  defp simulate(moons, steps) do
    moons
    |> Stream.iterate(&tick/1)
    |> Stream.take(1 + steps)
    |> Enum.take(-1)
    |> List.last()
  end

  defp tick(moons) do
    for m <- moons do
      vel = apply_gravities(m, moons -- [m])
      %{pos: move(m.pos, vel), vel: vel}
    end
  end

  defp move({x, y, z}, {dx, dy, dz}) do
    {x + dx, y + dy, z + dz}
  end

  defp apply_gravities(%{pos: {x0, y0, z0}, vel: vel}, rest) do
    Enum.reduce(rest, vel, fn %{pos: {x, y, z}}, {vx, vy, vz} ->
      {
        vx + diff(x0, x),
        vy + diff(y0, y),
        vz + diff(z0, z)
      }
    end)
  end

  defp diff(a, a), do: 0
  defp diff(a, b) when a < b, do: 1
  defp diff(a, b) when a > b, do: -1

  defp to_energy(moons) when is_list(moons) do
    Enum.reduce(moons, 0, &(to_energy(&1) + &2))
  end

  defp to_energy(%{pos: {x, y, z}, vel: {vx, vy, vz}}) do
    (abs(x) + abs(y) + abs(z)) * (abs(vx) + abs(vy) + abs(vz))
  end
end
