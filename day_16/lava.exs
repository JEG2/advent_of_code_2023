defmodule Lava do
  def read_input(path) do
    path
    |> File.stream!()
    |> Stream.with_index()
    |> Enum.reduce(Map.new(), fn {line, y}, acc ->
      line
      |> String.trim()
      |> String.graphemes()
      |> Stream.with_index()
      |> Enum.reduce(acc, fn {contents, x}, acc ->
        Map.put(acc, {x, y}, contents)
      end)
    end)
  end

  def solve_part_1(cave, start \\ {0, 0, :east}) do
    %{
      cave: cave,
      beam: start,
      splits: [],
      energized: MapSet.new()
    }
    |> Stream.iterate(fn state ->
      # IO.inspect(beam: state.beam, splits: state.splits)
      # IO.gets("--")
      if not MapSet.member?(state.energized, state.beam) do
        {x, y, _direction} = state.beam

        case Map.get(state.cave, {x, y}) do
          floor when not is_nil(floor) ->
            {beam, splits} = advance(state.beam, floor, state.splits)

            %{
              state
              | beam: beam,
                splits: splits,
                energized: MapSet.put(state.energized, state.beam)
            }

          nil ->
            case state.splits do
              [beam | splits] -> %{state | beam: beam, splits: splits}
              [] -> %{state | beam: nil}
            end
        end
      else
        case state.splits do
          [beam | splits] -> %{state | beam: beam, splits: splits}
          [] -> %{state | beam: nil}
        end
      end
    end)
    |> Enum.find(fn state -> is_nil(state.beam) and state.splits == [] end)
    |> Map.fetch!(:energized)
    |> Enum.into(MapSet.new(), fn {x, y, _direction} -> {x, y} end)
    |> MapSet.size()
  end

  def solve_part_2(cave) do
    xys = Map.keys(cave)
    max_x = xys |> Enum.map(&elem(&1, 0)) |> Enum.max()
    max_y = xys |> Enum.map(&elem(&1, 1)) |> Enum.max()

    Stream.concat([
      Enum.map(0..max_x//1, fn x -> {x, 0, :south} end),
      Enum.map(0..max_x//1, fn x -> {x, max_y, :north} end),
      Enum.map(0..max_y//1, fn y -> {0, y, :east} end),
      Enum.map(0..max_y//1, fn y -> {max_x, y, :west} end)
    ])
    |> Stream.map(fn start -> solve_part_1(cave, start) end)
    |> Enum.max()
  end

  defp advance({x, y, :north}, floor, splits) when floor in ~w[. |] do
    {{x, y - 1, :north}, splits}
  end

  defp advance({x, y, :north}, "-", splits) do
    {{x - 1, y, :west}, [{x + 1, y, :east} | splits]}
  end

  defp advance({x, y, :north}, "/", splits) do
    {{x + 1, y, :east}, splits}
  end

  defp advance({x, y, :north}, "\\", splits) do
    {{x - 1, y, :west}, splits}
  end

  defp advance({x, y, :south}, floor, splits) when floor in ~w[. |] do
    {{x, y + 1, :south}, splits}
  end

  defp advance({x, y, :south}, "-", splits) do
    {{x - 1, y, :west}, [{x + 1, y, :east} | splits]}
  end

  defp advance({x, y, :south}, "/", splits) do
    {{x - 1, y, :west}, splits}
  end

  defp advance({x, y, :south}, "\\", splits) do
    {{x + 1, y, :east}, splits}
  end

  defp advance({x, y, :east}, floor, splits) when floor in ~w[. -] do
    {{x + 1, y, :east}, splits}
  end

  defp advance({x, y, :east}, "|", splits) do
    {{x, y - 1, :north}, [{x, y + 1, :south} | splits]}
  end

  defp advance({x, y, :east}, "/", splits) do
    {{x, y - 1, :north}, splits}
  end

  defp advance({x, y, :east}, "\\", splits) do
    {{x, y + 1, :south}, splits}
  end

  defp advance({x, y, :west}, floor, splits) when floor in ~w[. -] do
    {{x - 1, y, :west}, splits}
  end

  defp advance({x, y, :west}, "|", splits) do
    {{x, y - 1, :north}, [{x, y + 1, :south} | splits]}
  end

  defp advance({x, y, :west}, "/", splits) do
    {{x, y + 1, :south}, splits}
  end

  defp advance({x, y, :west}, "\\", splits) do
    {{x, y - 1, :north}, splits}
  end
end

System.argv()
|> hd()
|> Lava.read_input()
|> Lava.solve_part_2()
|> IO.inspect()
