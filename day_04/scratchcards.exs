defmodule Scratchcards do
  def read_input(path) do
    path
    |> File.stream!()
    |> Enum.into(Map.new(), fn line ->
      ["Card" <> id, winning, yours] =
        line
        |> String.trim()
        |> String.split(~r{(?::\s*|\s*\|\s*)})

      id = id |> String.trim() |> String.to_integer()

      {
        id,
        %{id: id, winning: to_number_set(winning), yours: to_number_set(yours)}
      }
    end)
  end

  def solve_part_1(cards) do
    cards
    |> Map.values()
    |> Enum.map(fn c ->
      c.yours
      |> MapSet.intersection(c.winning)
      |> Enum.reduce(0, fn
        _n, 0 -> 1
        _n, score -> score + score
      end)
    end)
    |> Enum.sum()
  end

  def solve_part_2(cards) do
    yields =
      cards
      |> Map.values()
      |> Enum.into(Map.new(), fn c ->
        matches =
          c.yours
          |> MapSet.intersection(c.winning)
          |> MapSet.size()

        {c.id, Enum.map(1..matches//1, fn id_offset -> c.id + id_offset end)}
      end)

    cards
    |> Map.keys()
    |> count_cards(yields)
  end

  defp to_number_set(text) do
    text
    |> String.split()
    |> MapSet.new()
  end

  defp count_cards(current, yields, count \\ 0)
  defp count_cards([], _yields, count), do: count

  defp count_cards(current, yields, count) do
    current
    |> Enum.flat_map(fn id -> Map.fetch!(yields, id) end)
    |> count_cards(yields, count + length(current))
  end
end

System.argv()
|> hd()
|> Scratchcards.read_input()
|> Scratchcards.solve_part_2()
|> IO.inspect()
