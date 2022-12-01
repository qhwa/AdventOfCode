defmodule GeneticAlgorithm do
  def run(options) do
    terminate_fun = Keyword.fetch!(options, :terminate?)

    {_max_gen, [best | _]} =
      {0, init_population(options)}
      |> Stream.iterate(fn {generation, population} ->
        [best | _] = population
        IO.inspect(best |> Map.take([:fitness, :generation]), label: "#{generation}")

        {generation + 1, evolve(population, options, generation)}
      end)
      |> Stream.drop_while(&(!terminate_fun.(&1)))
      |> Stream.take(1)
      |> Enum.at(0)

    best
  end

  defp init_population(options) do
    genotype = Keyword.fetch!(options, :genotype)
    size = Keyword.get(options, :init_population_size, 20)
    for _ <- 1..size, do: %{generation: 0, genes: genotype.()}
  end

  defp evolve(population, options, generation) do
    fitness_fun = Keyword.fetch!(options, :fitness_fun)
    genotype = Keyword.fetch!(options, :genotype)

    population
    |> calculate_fitness(fitness_fun)
    |> selection(options)
    |> crossover(options, generation)
    |> mutation(options)
    |> uniq(genotype, generation)
  end

  defp calculate_fitness(population, fitness_fun) do
    population
    |> Stream.map(fn
      %{fitness: f} = chromosome when is_number(f) ->
        chromosome

      chromosome ->
        Map.put(
          chromosome,
          :fitness,
          fitness_fun.(chromosome)
        )
    end)
    |> Enum.sort_by(
      fn
        %{fitness: f} when is_number(f) ->
          {:ok, f}

        _ ->
          nil
      end,
      :desc
    )
  end

  defp selection(population, _options) do
    select_count = Enum.count(population) |> div(2)
    Enum.take(population, select_count)
  end

  defp crossover(population, options, generation) do
    crossover_fun = Keyword.fetch!(options, :crossover_fun)

    population
    |> Stream.chunk_every(2, 2, :discard)
    |> Stream.flat_map(fn [chromosome_a, chromosome_b] ->
      crossover_fun.(chromosome_a.genes, chromosome_b.genes)
      |> Stream.map(fn genes ->
        if Enum.any?(population, &(&1.genes == genes)) do
          Keyword.fetch!(options, :genotype).()
        else
          genes
        end
      end)
      |> Enum.map(
        &%{
          generation: generation + 1,
          fitness: nil,
          genes: &1
        }
      )
    end)
    |> then(&Enum.concat(population, &1))
  end

  defp mutation([first | rest] = population, options) do
    case Keyword.get(options, :mutation_fun) do
      f when is_function(f, 1) ->
        [first | Enum.map(rest, f)]

      _ ->
        population
    end
  end

  defp uniq(population, genotype, generation) do
    rest =
      population
      |> Enum.uniq_by(& &1.genes)

    repair =
      0..(length(population) - length(rest))
      |> Enum.map(fn _ ->
        %{
          genes: genotype.(),
          fitness: nil,
          generation: generation + 1
        }
      end)

    rest ++ repair
  end
end

defmodule Y2021.Day15 do
  def p1 do
    risks =
      AOC.Input.stream("2021/day15.txt")
      |> parse_risks()

    {{max_x, _}, _} = Enum.max_by(risks, &elem(&1, 0))
    %{genes: dirs, fitness: f, generation: g} = find_safest_path(risks)

    IO.inspect({g, f}, label: :best)

    Enum.reduce_while(dirs, {0, 0, 0}, fn
      _, {^max_x, ^max_x, risk} ->
        IO.inspect(risk, label: :end)
        {:halt, risk}

      {dx, dy}, {x, y, risk} ->
        r = risks[{x, y}]
        IO.inspect({x, y, r}, label: risk)
        {:cont, {x + dx, y + dy, risk + r}}
    end)
  end

  defp parse_risks(input_stream) do
    input_stream
    |> Stream.with_index()
    |> Stream.flat_map(fn {line, y} ->
      String.graphemes(line)
      |> Stream.with_index()
      |> Enum.map(fn {char, x} ->
        {{x, y}, String.to_integer(char)}
      end)
    end)
    |> Enum.into(%{})
    |> Map.put({0, 0}, 0)
  end

  def find_safest_path(risks) do
    genotype = genotype(risks)

    GeneticAlgorithm.run(
      init_population_size: 64,
      genotype: genotype,
      fitness_fun: fitness(risks),
      crossover_fun: fn g1, g2 ->
        {c1, c2} =
          g1
          |> Stream.zip(g2)
          |> Stream.map(fn {x, y} ->
            if :rand.uniform() < 0.1 do
              {x, y}
            else
              {y, x}
            end
          end)
          |> Enum.unzip()

        [c1, c2]
      end,
      mutation_fun: fn %{genes: genes} = chromosome ->
        if :rand.uniform() < 0.005 do
          Map.merge(chromosome, %{
            genes:
              Enum.map(genes, fn {dx, dy} = g ->
                if :rand.uniform() < 0.5 do
                  {dy, dx}
                else
                  g
                end
              end),
            generation: chromosome.generation + 1,
            fitness: nil
          })
        else
          chromosome
        end
      end,
      terminate?: fn
        {_generation, [%{fitness: -40} | _]} -> true
        {generation, _population} when generation > 50000 -> true
        _ -> false
      end
    )
  end

  defp genotype(risks) do
    {{width, _}, _} = Enum.max_by(risks, &elem(&1, 0))

    longest = width * 2 + 1
    dirs = [{0, 1}, {1, 0}]

    fn ->
      1..longest
      |> Enum.map(fn _ -> Enum.random(dirs) end)
    end
  end

  defp fitness(risks) do
    start = {0, 0}
    {dest, _} = Enum.max_by(risks, fn {pos, _} -> pos end)
    max_risk = Map.values(risks) |> Enum.sum()
    IO.inspect(max_risk, label: "max risk")
    IO.inspect(dest, label: "destination")

    fn %{genes: directions} ->
      {_, risk_level} =
        Enum.reduce_while(directions, {start, 0}, fn dir, {pos, acc} ->
          new_pos = new_pos(pos, dir)

          case risks do
            %{^pos => risk} when new_pos == dest ->
              {:halt, {new_pos, acc + risk}}

            %{^pos => risk} ->
              {:cont, {new_pos, acc + risk}}

            %{} ->
              {:halt, {new_pos, :error}}
          end
        end)

      case risk_level do
        n when is_integer(n) -> -n
        :error -> -max_risk
      end
    end
  end

  defp new_pos({x, y}, {dx, dy}), do: {x + dx, y + dy}
end

Y2021.Day15.p1() |> IO.inspect(label: "Part 1")
