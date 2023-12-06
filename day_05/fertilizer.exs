defmodule Fertilizer do
  def read_input(path) do
    {seeds, mapping, _conversion} =
      path
      |> File.stream!()
      |> Stream.map(&String.trim/1)
      |> Enum.reduce({[], Map.new(), nil}, fn
        "seeds: " <> seeds, {[], mapping, nil} ->
          {to_number_list(seeds), mapping, nil}

        "", {seeds, mapping, conversion} ->
          {seeds, mapping, conversion}

        line, {seeds, mapping, conversion} ->
          if String.ends_with?(line, " map:") do
            [from, to] =
              line
              |> String.slice(0..-6)
              |> String.split("-to-")

            {seeds, Map.put(mapping, from, %{type: to, ranges: []}), from}
          else
            [dest, source, limit] = to_number_list(line)
            ranges = [{dest, source, limit} | mapping[conversion].ranges]
            {seeds, put_in(mapping, [conversion, :ranges], ranges), conversion}
          end
      end)

    {seeds, mapping}
  end

  def solve_part_1({seeds, mapping}) do
    lowest_location({Enum.map(seeds, fn n -> [{"seed", n}] end), mapping})
  end

  def solve_part_2({seeds, mapping}) do
    seeds
    # |> Enum.chunk_every(2)
    # |> Enum.map(fn [start, count] -> {start, start + count - 1} end)
    # |> Enum.flat_map_reduce("seed", fn ranges, from ->
    #   map = mapping[from]

    #   ranges =
    #     ranges
    #     |> Stream.unfold(fn
    #       {f, t} when f > t ->
    #         nil

    #       {f, t} ->
    #         Enum.find(map.ranges, {0, 0, 0}, fn {_dest, source, limit} ->
    #           f >= source and f < source + limit
    #         end)
    #         |> case do
    #           {0, 0, 0} ->
    #             source =
    #               map.ranges
    #               |> Enum.map(fn r -> elem(r, 1) - 1 end)
    #               |> Enum.min_by(fn s -> s > f and s <= t end, &<=/2, fn -> t end)

    #             {{f, source}, {source + 1, t}}

    #           {dest, source, limit} ->
    #             {
    #               {f - source + dest, min(t, dest + limit)},
    #               {min(t, dest + limit) + 1, t}
    #             }
    #         end
    #     end)
    #     |> Enum.to_list()

    #   {ranges, map.type}
    #   |> IO.inspect()
    # end)
  end

  defp to_number_list(text) do
    text
    |> String.split()
    |> Enum.map(&String.to_integer/1)
  end

  def lowest_location({[[{"location", _n} | _] | _] = conversions, _mapping}) do
    conversions
    |> Enum.map(fn c -> c |> hd() |> elem(1) end)
    |> Enum.min()
  end

  def lowest_location({conversions, mapping}) do
    conversions =
      Enum.map(conversions, fn [{from, n} | _earlier] = c ->
        map = mapping[from]

        {dest, source, _limit} =
          Enum.find(map.ranges, {0, 0, 0}, fn {_dest, source, limit} ->
            n >= source and n < source + limit
          end)

        [{map.type, n - source + dest} | c]
      end)

    lowest_location({conversions, mapping})
  end
end

System.argv()
|> hd()
|> Fertilizer.read_input()
|> Fertilizer.solve_part_2()
|> IO.inspect()
