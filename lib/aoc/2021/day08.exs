defmodule Y2021.Day08 do
  @moduledoc """
  Solved with a genetic algorithm.
  https://adventofcode.com/2021/day/8

  Run with: `mix run lib/aoc/2021/day08.exs`
  """

  use Bitwise

  @seg_pattens [
    0b1110111,
    0b0010010,
    0b1011101,
    0b1011011,
    0b0111010,
    0b1101011,
    0b1101111,
    0b1010010,
    0b1111111,
    0b1111011
  ]

  @signal_to_numbers @seg_pattens
                     |> Stream.with_index()
                     |> Stream.map(fn {segs, n} ->
                       chars =
                         0..7
                         |> Enum.reduce([], fn pos, chars ->
                           case segs &&& 1 <<< pos do
                             0 ->
                               chars

                             _ ->
                               [?g - pos | chars]
                           end
                         end)

                       {chars, n}
                     end)
                     |> Enum.into(%{})

  def p1 do
    AOC.Input.stream("2021/day08.txt")
    |> Stream.flat_map(fn line ->
      [_, displays] = String.split(line, "|", trim: true)

      displays
      |> String.split(" ", trim: true)
    end)
    |> Stream.filter(&(byte_size(&1) in [2, 3, 4, 7]))
    |> Enum.count()
  end

  def p2 do
    AOC.Input.stream("2021/day08.txt")
    |> Stream.map(fn line ->
      {pattens, ["|" | displays]} =
        String.split(line, " ")
        |> Enum.split(10)

      pattens
      |> normalize_pattens()
      |> decode_mapping()
      |> decode_number(displays)
      |> Integer.undigits()
    end)
    |> Enum.sum()
  end

  defp normalize_pattens(pattens) do
    Enum.map(pattens, fn p ->
      String.to_charlist(p)
      |> Enum.sort()
      |> to_string()
    end)
  end

  defp decode_mapping(recorded_pattens) do
    %{genes: genes} =
      GeneticAlgorithm.run(
        init_population_size: 36,
        genotype: fn -> Enum.shuffle(?a..?g) end,
        fitness_fun: fitness(recorded_pattens),
        crossover_fun: fn g1, g2 ->
          point = :rand.uniform(5)
          {g11, g12} = Enum.split(g1, point)
          {g21, g22} = Enum.split(g2, point)

          [repair_genes(g11 ++ g22), repair_genes(g21 ++ g12)]
        end,
        mutation_fun: fn chromosome ->
          if :rand.uniform() < 0.01 do
            Map.merge(chromosome, %{
              genes: Enum.shuffle(chromosome.genes),
              generation: chromosome.generation + 1,
              fitness: nil
            })
          else
            chromosome
          end
        end,
        terminate?: fn {_generation, [best | _]} ->
          match?(%{fitness: 10}, best)
        end
      )

    genes
    |> Enum.zip(?a..?g)
    |> Enum.into(%{})
  end

  defp fitness(recorded_pattens) do
    fn chromosome ->
      signal_pattens =
        @seg_pattens
        |> Enum.map(fn segs ->
          0..6
          |> Enum.reduce([], fn pos, acc ->
            case segs &&& 1 <<< pos do
              0 ->
                acc

              _ ->
                [Enum.at(chromosome.genes, 6 - pos) | acc]
            end
          end)
          |> Enum.sort()
          |> to_string()
        end)

      signal_pattens
      |> Enum.count(&(&1 in recorded_pattens))
    end
  end

  defp repair_genes(genes) do
    full_genes = Enum.to_list(?a..?g)

    genes
    |> Enum.uniq()
    |> then(fn genes ->
      genes
      |> Enum.concat(Enum.shuffle(full_genes -- genes))
    end)
  end

  defp decode_number(patten, displays) do
    displays
    |> Stream.map(&String.to_charlist/1)
    |> Stream.map(fn chars ->
      chars
      |> Stream.map(&Map.get(patten, &1))
      |> Enum.sort()
    end)
    |> Stream.map(&Map.get(@signal_to_numbers, &1))
    |> Enum.to_list()
  end
end

defmodule GeneticAlgorithm do
  def run(options) do
    terminate_fun = Keyword.fetch!(options, :terminate?)

    {_max_gen, [best | _]} =
      {0, init_population(options)}
      |> Stream.iterate(fn {generation, population} ->
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

    population
    |> calculate_fitness(fitness_fun)
    |> selection(options)
    |> crossover(options, generation)
    |> mutation(options)
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

  defp mutation(population, options) do
    case Keyword.get(options, :mutation_fun) do
      f when is_function(f, 1) ->
        Enum.map(population, f)

      _ ->
        population
    end
  end
end

Y2021.Day08.p1() |> IO.inspect(label: "part 1")
Y2021.Day08.p2() |> IO.inspect(label: "part 2")
