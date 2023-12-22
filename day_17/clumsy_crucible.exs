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
      goal: {max_x, max_y},
      facing: :south,
      straight_moves: 0,
      location: {0, 0},
      path: [{0, 0}],
      heat_loss: 0
    }
  end

  def solve_part_1(state) do
    {:gb_sets.singleton({state.heat_loss, state}), MapSet.new([state.location])}
    |> Stream.iterate(fn {priority_queue, visited} ->
      {{_heat_loss, state}, q} = :gb_sets.take_smallest(priority_queue)

      state
      |> find_possible_moves()
      |> remove_illegal_moves(state, visited)
      |> make_moves(state)
      |> Enum.reduce({q, visited}, fn s, {q, v} ->
        {:gb_sets.add({s.heat_loss, s}, q), MapSet.put(v, state.location)}
      end)
    end)
    |> Enum.find(fn {priority_queue, _visited} ->
      {_heat_loss, state} = :gb_sets.smallest(priority_queue)
      state.location == state.goal
    end)
    |> elem(0)
    |> :gb_sets.smallest()
    |> then(fn {_heat_loss, s} -> s.path end)
  end

  defp find_possible_moves(state) do
    directions =
      case state.facing do
        :north -> ~w[west north east]a
        :south -> ~w[west south east]a
        :east -> ~w[north east south]a
        :west -> ~w[south west north]a
      end

    {x, y} = state.location

    Enum.map(directions, fn
      :north -> {:north, {x, y - 1}}
      :south -> {:south, {x, y + 1}}
      :east -> {:east, {x + 1, y}}
      :west -> {:west, {x - 1, y}}
    end)
  end

  defp remove_illegal_moves(moves, state, visited) do
    Enum.filter(moves, fn {direction, xy} ->
      (state.straight_moves < 3 or direction != state.facing) and
        Map.has_key?(state.blocks, xy) and
        not MapSet.member?(visited, xy)
    end)
  end

  defp make_moves(moves, state) do
    Enum.map(moves, fn {direction, xy} ->
      straight_moves =
        if direction == state.facing do
          state.straight_moves + 1
        else
          1
        end

      %{
        state
        | facing: direction,
          straight_moves: straight_moves,
          location: xy,
          heat_loss: state.heat_loss + Map.fetch!(state.blocks, xy)
      }
    end)
  end
end

System.argv()
|> hd()
|> ClumsyCrucible.read_input()
|> ClumsyCrucible.solve_part_1()
|> IO.inspect()
