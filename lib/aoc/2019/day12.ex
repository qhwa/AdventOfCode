defmodule AOC.Y2019.Day12 do
  @moduledoc """
  @see http://adventofcode.com/2019/day/12
  """

  @moons [
    {-19, -4, 2},
    {-9, 8, -16},
    {-4, 5, -11},
    {1, 9, -13}
  ]

  def p1, do: simulate(@moons, 1000) |> to_energy()
  def p2, do: find_repeat_step(@moons)

  defp simulate(moons, n) do
    moons
    |> Enum.map(&%{pos: &1, vel: {0, 0, 0}})
    |> step(n)
  end

  defp step(moons, 0), do: moons
  defp step(moons, n), do: moons |> next_frame_3d() |> step(n - 1)

  defp next_frame_3d(moons) do
    Enum.map(moons, fn m ->
      vel = apply_gravities(m, moons)
      %{pos: apply_velocity(m.pos, vel), vel: vel}
    end)
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

  defp apply_velocity({x, y, z}, {vx, vy, vz}), do: {x + vx, y + vy, z + vz}

  defp to_energy(moons) when is_list(moons) do
    moons
    |> Stream.map(&to_energy/1)
    |> Enum.sum()
  end

  defp to_energy(%{pos: {x, y, z}, vel: {vx, vy, vz}}) do
    (abs(x) + abs(y) + abs(z)) * (abs(vx) + abs(vy) + abs(vz))
  end

  defp find_repeat_step(moons) do
    to_1d = fn i -> &{elem(&1, i), 0} end

    [
      moons |> Enum.map(to_1d.(0)),
      moons |> Enum.map(to_1d.(1)),
      moons |> Enum.map(to_1d.(2))
    ]
    |> Enum.map(&find_repeat_1d_step/1)
    |> Enum.reduce(&lcm/2)
  end

  defp find_repeat_1d_step(moons_1d) do
    search_loop(moons_1d, moons_1d, 0)
  end

  defp search_loop(t, t, step) when step > 0, do: step

  defp search_loop(current, target, step) do
    search_loop(next_frame_1d(current), target, step + 1)
  end

  defp next_frame_1d(moons_1d) do
    Enum.map(moons_1d, fn {pos, v} ->
      Enum.reduce(moons_1d, {pos + v, v}, fn {p, _}, {pos0, v0} ->
        d = diff(pos, p)
        {pos0 + d, v0 + d}
      end)
    end)
  end

  defp lcm(a, b), do: div(a * b, Integer.gcd(a, b))
end
