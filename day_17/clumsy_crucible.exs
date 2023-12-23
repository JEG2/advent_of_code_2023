defmodule ClumsyCrucible do
  def read_input(path) do
    blocks =
      path
      |> File.stream!()
      |> Stream.with_index()
      |> Enum.reduce(Map.new(), fn {line, y}, acc ->
        line
        |> String.trim()
        |> String.graphemes()
        |> Stream.with_index()
        |> Enum.reduce(acc, fn {heat_loss, x}, acc ->
          Map.put(acc, {x, y}, String.to_integer(heat_loss))
        end)
      end)

    max_x = blocks |> Map.keys() |> Enum.map(fn {x, _y} -> x end) |> Enum.max()
    max_y = blocks |> Map.keys() |> Enum.map(fn {_x, y} -> y end) |> Enum.max()

    %{
      blocks: blocks,
      source: {0, 0},
      target: {max_x, max_y}
    }
  end

  def solve_part_1(city) do
    %{
      dist: %{city.source => 0},
      prev: %{},
      q:
        :gb_sets.singleton({
          0,
          %{
            facing: :south,
            straight_moves: 0,
            xy: city.source
          }
        })
      # |> then(fn q ->
      #   city.blocks
      #   |> Map.keys()
      #   |> Kernel.--([city.source])
      #   |> Enum.reduce(q, fn xy, q -> :gb_sets.add({:infinity, xy}, q) end)
      # end)
    }
    |> Stream.iterate(fn state ->
      {{p, u}, q} = :gb_sets.take_smallest(state.q)
      # IO.inspect(u.xy)

      # for v <- each_neighbor(u, city) |> IO.inspect(), reduce: %{state | q: q} do
      for v <- each_neighbor(u, city), reduce: %{state | q: q} do
        %{dist: dist, prev: prev, q: q} = state ->
          # IO.inspect(v)
          # IO.gets("?")
          alt = p + Map.fetch!(city.blocks, v.xy)

          cond do
            p != Map.fetch!(dist, u.xy) ->
              IO.inspect(:skipped)
              state

            alt < Map.get(dist, v.xy, :infinity) ->
              %{
                dist: Map.put(dist, v.xy, alt),
                prev: Map.put(prev, v.xy, u.xy),
                q: :gb_sets.add({alt, v}, q)
              }

            # |> IO.inspect()

            true ->
              state
          end
      end
    end)
    |> Enum.find(fn state ->
      # {_p, u} = :gb_sets.smallest(state.q)
      # u.xy == city.target
      :gb_sets.size(state.q) == 0
    end)
    |> Map.fetch!(:dist)
    |> then(&(Map.keys(city.blocks) -- Map.keys(&1)))

    # |> then(fn state ->
    #   # IO.inspect(state.dist[{11, 12}])

    #   Stream.unfold(city.target, fn xy ->
    #     p = Map.get(state.prev, xy)

    #     if p do
    #       {p, p}
    #     else
    #       nil
    #     end
    #   end)
    #   |> Enum.to_list()
    # end)

    # |> Map.fetch!(:q)
    # |> :gb_sets.smallest()
    # |> elem(0)
  end

  defp each_neighbor(u, city) do
    directions =
      case u.facing do
        :north -> ~w[west north east]a
        :south -> ~w[west south east]a
        :east -> ~w[north east south]a
        :west -> ~w[south west north]a
      end

    {x, y} = u.xy

    directions
    |> Enum.map(fn
      :north -> %{facing: :north, xy: {x, y - 1}}
      :south -> %{facing: :south, xy: {x, y + 1}}
      :east -> %{facing: :east, xy: {x + 1, y}}
      :west -> %{facing: :west, xy: {x - 1, y}}
    end)
    |> Enum.filter(fn v ->
      (u.straight_moves < 3 or v.facing != u.facing) and
        Map.has_key?(city.blocks, v.xy)
    end)
    |> Enum.map(fn v ->
      straight_moves =
        if v.facing == u.facing do
          u.straight_moves + 1
        else
          1
        end

      Map.put(v, :straight_moves, straight_moves)
    end)
  end
end

System.argv()
|> hd()
|> ClumsyCrucible.read_input()
|> ClumsyCrucible.solve_part_1()
|> IO.inspect()
