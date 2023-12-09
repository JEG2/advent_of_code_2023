defmodule CamelCards do
  def read_input(path) do
    path
    |> File.stream!()
    |> Enum.map(fn line ->
      [cards, bid] =
        line
        |> String.trim()
        |> String.split()

      {String.graphemes(cards), String.to_integer(bid)}
    end)
  end

  def solve_part_1(hands) do
    hands
    |> Enum.sort(fn {cards_1, _bid_1}, {cards_2, _bid_2} ->
      rank_1 = rank(cards_1)
      rank_2 = rank(cards_2)

      if rank_1 == rank_2 do
        break_tie(cards_1, cards_2, &card_to_number/1)
      else
        rank_1 <= rank_2
      end
    end)
    |> score()
  end

  def solve_part_2(hands) do
    hands
    |> Enum.sort(fn {cards_1, _bid_1}, {cards_2, _bid_2} ->
      rank_1 = rank_with_jokers(cards_1)
      rank_2 = rank_with_jokers(cards_2)

      if rank_1 == rank_2 do
        break_tie(cards_1, cards_2, &card_to_number_with_jokers/1)
      else
        rank_1 <= rank_2
      end
    end)
    |> score()
  end

  defp rank(cards) do
    cards
    |> Enum.frequencies()
    |> Map.values()
    |> Enum.sort(:desc)
    |> rank_to_number()
  end

  defp rank_to_number([5]), do: 6
  defp rank_to_number([4, 1]), do: 5
  defp rank_to_number([3, 2]), do: 4
  defp rank_to_number([3, 1, 1]), do: 3
  defp rank_to_number([2, 2, 1]), do: 2
  defp rank_to_number([2, 1, 1, 1]), do: 1
  defp rank_to_number([1, 1, 1, 1, 1]), do: 0

  defp break_tie(cards_1, cards_2, rule) do
    {n_1, n_2} =
      Enum.zip(cards_1, cards_2)
      |> Enum.map(fn {c_1, c_2} ->
        {rule.(c_1), rule.(c_2)}
      end)
      |> Enum.find(fn {n_1, n_2} -> n_1 != n_2 end)

    n_1 <= n_2
  end

  defp card_to_number("2"), do: 0
  defp card_to_number("3"), do: 1
  defp card_to_number("4"), do: 2
  defp card_to_number("5"), do: 3
  defp card_to_number("6"), do: 4
  defp card_to_number("7"), do: 5
  defp card_to_number("8"), do: 6
  defp card_to_number("9"), do: 7
  defp card_to_number("T"), do: 8
  defp card_to_number("J"), do: 9
  defp card_to_number("Q"), do: 10
  defp card_to_number("K"), do: 11
  defp card_to_number("A"), do: 12

  defp score(hands) do
    hands
    |> Enum.with_index(1)
    |> Enum.map(fn {{_cards, bid}, rank} -> bid * rank end)
    |> Enum.sum()
  end

  defp rank_with_jokers(cards) do
    cards
    |> Enum.frequencies()
    |> then(fn
      %{"J" => 5} ->
        %{"J" => 5}

      counts ->
        {jokers, counts} = Map.pop(counts, "J", 0)
        {highest, _count} = Enum.max_by(counts, fn {_card, count} -> count end)
        Map.update!(counts, highest, &(&1 + jokers))
    end)
    |> Map.values()
    |> Enum.sort(:desc)
    |> rank_to_number()
  end

  defp card_to_number_with_jokers("J"), do: -1
  defp card_to_number_with_jokers(card), do: card_to_number(card)
end

System.argv()
|> hd()
|> CamelCards.read_input()
|> CamelCards.solve_part_2()
|> IO.inspect()
