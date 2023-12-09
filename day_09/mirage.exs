defmodule Mirage do
  def read_input(path) do
    path
    |> File.stream!()
    |> Stream.map(fn line -> line |> String.trim() |> to_number_list() end)
  end

  def solve_part_1(sequences) do
    extrapolate(sequences, fn row, acc -> List.last(row) + acc end)
  end

  def solve_part_2(sequences) do
    extrapolate(sequences, fn row, acc -> List.first(row) - acc end)
  end

  defp to_number_list(text) do
    text
    |> String.split()
    |> Enum.map(&String.to_integer/1)
  end

  defp extrapolate(sequences, f) do
    sequences
    |> Enum.map(fn s ->
      s
      |> Stream.iterate(fn row ->
        row
        |> Enum.chunk_every(2, 1, :discard)
        |> Enum.map(fn [r, l] -> l - r end)
      end)
      |> Enum.take_while(fn row -> not Enum.all?(row, fn n -> n == 0 end) end)
      |> Enum.reverse()
      |> Enum.reduce(0, f)
    end)
    |> Enum.sum()
  end
end

System.argv()
|> hd()
|> Mirage.read_input()
|> Mirage.solve_part_2()
|> IO.inspect()
