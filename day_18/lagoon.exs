defmodule Lagoon do
  @directions %{"0" => "R", "1" => "D", "2" => "L", "3" => "U"}
  def read_input(path) do
    path
    |> File.stream!()
    |> Enum.map(fn line ->
      [direction, count, color] =
        line
        |> String.trim()
        |> String.split()

      {direction, String.to_integer(count), String.slice(color, 2..-2)}
    end)
  end

  def solve_part_1(plan) do
    plan
    |> Enum.reduce(
      {{0, 0}, MapSet.new([{0, 0}])},
      fn {direction, count, _color}, {xy, dig} ->
        moves =
          case direction do
            "R" -> Stream.iterate(xy, fn {x, y} -> {x + 1, y} end)
            "D" -> Stream.iterate(xy, fn {x, y} -> {x, y + 1} end)
            "L" -> Stream.iterate(xy, fn {x, y} -> {x - 1, y} end)
            "U" -> Stream.iterate(xy, fn {x, y} -> {x, y - 1} end)
          end

        moves
        |> Stream.drop(1)
        |> Stream.take(count)
        |> Enum.reduce({nil, dig}, fn xy, {_last, dig} ->
          {xy, MapSet.put(dig, xy)}
        end)
      end
    )
    |> elem(1)
    |> then(fn dig ->
      min_x = dig |> Enum.map(fn {x, _y} -> x end) |> Enum.min()

      {edge_x, edge_y} =
        Enum.find(dig, fn {x, y} ->
          x == min_x and not MapSet.member?(dig, {x + 1, y})
        end)

      {[{edge_x + 1, edge_y}], dig}
    end)
    |> Stream.iterate(fn {[{x, y} | stack], dig} ->
      next =
        Enum.reject([{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}], fn xy ->
          MapSet.member?(dig, xy)
        end)

      {next ++ stack, Enum.into(next, dig)}
    end)
    |> Enum.find(fn {stack, _dig} -> stack == [] end)
    |> elem(1)
    |> MapSet.size()
  end

  def solve_part_2(plan) do
    vertices =
      plan
      |> Enum.map(fn {_direction, _count, color} ->
        <<count::binary-size(5), direction::binary-size(1)>> = color
        {Map.fetch!(@directions, direction), String.to_integer(count, 16)}
      end)
      |> Enum.reduce([{0, 0}], fn {direction, count}, [{x, y} | _rest] = acc ->
        next =
          case direction do
            "R" -> {x + count, y}
            "D" -> {x, y + count}
            "L" -> {x - count, y}
            "U" -> {x, y - count}
          end

        [next | acc]
      end)
      |> Enum.uniq()

    count = length(vertices)

    cx = vertices |> Enum.map(&elem(&1, 0)) |> Enum.sum() |> Kernel./(count)
    cy = vertices |> Enum.map(&elem(&1, 1)) |> Enum.sum() |> Kernel./(count)

    vertices =
      Enum.sort(vertices, fn {ax, ay}, {bx, by} ->
        ac = rem(round(:math.atan2(ax - cx, ay - cy) * (180 / :math.pi())) + 360, 360)
        bc = rem(round(:math.atan2(bx - cx, by - cy) * (180 / :math.pi())) + 360, 360)
        ac - bc
      end)
  end
end

System.argv()
|> hd()
|> Lagoon.read_input()
|> Lagoon.solve_part_2()
|> IO.inspect()
