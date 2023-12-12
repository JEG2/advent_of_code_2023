defmodule PipeMaze do
  def read_input(path) do
    graph = :digraph.new()

    stream_nodes(path, fn {node, x, y} ->
      :digraph.add_vertex(graph, {x, y}, node)
    end)

    stream_nodes(path, fn
      {"|", x, y} ->
        connect_pipes(graph, {x, y}, {x, y - 1}, {x, y + 1})

      {"-", x, y} ->
        connect_pipes(graph, {x, y}, {x - 1, y}, {x + 1, y})

      {"L", x, y} ->
        connect_pipes(graph, {x, y}, {x, y - 1}, {x + 1, y})

      {"J", x, y} ->
        connect_pipes(graph, {x, y}, {x, y - 1}, {x - 1, y})

      {"7", x, y} ->
        connect_pipes(graph, {x, y}, {x, y + 1}, {x - 1, y})

      {"F", x, y} ->
        connect_pipes(graph, {x, y}, {x, y + 1}, {x + 1, y})

      {"S", _x, _y} ->
        :skip
    end)

    {sx, sy} =
      s =
      graph
      |> :digraph.vertices()
      |> Enum.find(fn v -> get_label(graph, v) == "S" end)

    case %{
      up: get_label(graph, {sx, sy - 1}) in ~w[| F 7],
      down: get_label(graph, {sx, sy + 1}) in ~w[| L J],
      left: get_label(graph, {sx - 1, sy}) in ~w[- F L],
      right: get_label(graph, {sx + 1, sy}) in ~w[- 7 J]
    } do
      %{up: true, down: true} -> :digraph.add_vertex(graph, s, "|")
      %{left: true, right: true} -> :digraph.add_vertex(graph, s, "-")
      %{down: true, right: true} -> :digraph.add_vertex(graph, s, "F")
      %{down: true, left: true} -> :digraph.add_vertex(graph, s, "7")
      %{up: true, right: true} -> :digraph.add_vertex(graph, s, "L")
      %{up: true, left: true} -> :digraph.add_vertex(graph, s, "J")
    end

    start =
      graph
      |> :digraph.in_edges(s)
      |> hd()
      |> elem(0)

    :digraph.add_edge(graph, {s, start}, s, start, [])
    :digraph.del_edge(graph, {start, s})

    {graph, s}
  end

  def solve_part_1({graph, s}) do
    graph
    |> :digraph.get_cycle(s)
    |> length()
    |> div(2)
  end

  def solve_part_2({graph, s}) do
    polygon = :digraph.get_cycle(graph, s)
    {min_x, max_x} = polygon |> Enum.map(fn {x, _y} -> x end) |> Enum.min_max()
    {min_y, max_y} = polygon |> Enum.map(fn {_x, y} -> y end) |> Enum.min_max()

    for x <- min_x..max_x, y <- min_y..max_y, {x, y} not in polygon, reduce: 0 do
      count ->
        crossed_lines =
          1..max(max_x, max_y)
          |> Enum.map(fn offset ->
            point = {x + offset, y + offset}

            if point in polygon do
              case :digraph.vertex(graph, point) do
                {_node, "S"} -> raise "unhandled error"
                false -> 0
                {_node, corner} when corner in ~w[L 7] -> 2
                _node -> 1
              end
            else
              0
            end
          end)
          |> Enum.sum()

        if rem(crossed_lines, 2) == 1 do
          count + 1
        else
          count
        end
    end
  end

  defp stream_nodes(path, f) do
    path
    |> File.stream!()
    |> Stream.with_index()
    |> Enum.each(fn {line, y} ->
      line
      |> String.trim()
      |> String.graphemes()
      |> Stream.with_index()
      |> Enum.each(fn
        {".", _x} -> :skip
        {node, x} -> f.({node, x, y})
      end)
    end)
  end

  defp connect_pipes(graph, from, to_1, to_2) do
    :digraph.add_edge(graph, {from, to_1}, from, to_1, [])
    :digraph.add_edge(graph, {from, to_2}, from, to_2, [])
  end

  defp get_label(graph, vertex) do
    case :digraph.vertex(graph, vertex) do
      false -> nil
      {^vertex, label} -> label
    end
  end
end

System.argv()
|> hd()
|> PipeMaze.read_input()
|> PipeMaze.solve_part_2()
|> IO.inspect()
