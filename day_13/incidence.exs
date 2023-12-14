defmodule Incidence do
  def read_input(path) do
    path
    |> File.stream!()
    |> Enum.map(&String.trim/1)
    |> Enum.chunk_while(
      [],
      fn
        "", acc ->
          {:cont, Enum.reverse(acc), []}

        line, acc ->
          {:cont, [line | acc]}
      end,
      fn acc ->
        {:cont, Enum.reverse(acc), []}
      end
    )
    |> Enum.map(fn lines ->
      lines
      |> Stream.with_index()
      |> Enum.reduce(Map.new(), fn {line, y}, acc ->
        Map.put(acc, y, line)
      end)
    end)
  end

  def solve_part_1(patterns) do
    patterns
    |> Enum.map(fn rows ->
      case find_reflection(rows) do
        [low, _high] ->
          (low + 1) * 100

        nil ->
          rows
          |> rows_to_cols()
          |> find_reflection()
          |> then(fn [low, _high] -> low + 1 end)
      end
    end)
    |> Enum.sum()
  end

  defp find_reflection(cols_or_rows) do
    max = cols_or_rows |> Map.keys() |> Enum.max()

    cols_or_rows
    |> Map.keys()
    |> Enum.sort()
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.find(fn [low, high] ->
      Enum.zip(low..0//-1, high..max//1)
      |> Enum.all?(fn {low, high} ->
        Map.fetch!(cols_or_rows, low) == Map.fetch!(cols_or_rows, high)
      end)
    end)
  end

  defp rows_to_cols(rows) do
    rows
    |> Enum.reduce(Map.new(), fn {y, r}, acc ->
      r
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {content, x}, acc ->
        Map.update(acc, x, [{y, content}], fn col -> [{y, content} | col] end)
      end)
    end)
    |> Enum.into(Map.new(), fn {x, col} ->
      {
        x,
        col
        |> Enum.sort()
        |> Enum.map(fn {_y, content} -> content end)
        |> Enum.join()
      }
    end)
  end
end

System.argv()
|> hd()
|> Incidence.read_input()
|> Incidence.solve_part_1()
|> IO.inspect()
