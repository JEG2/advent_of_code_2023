defmodule Aplenty do
  def read_input(path) do
    input =
      path
      |> File.stream!()
      |> Stream.map(&String.trim/1)

    workflows =
      input
      |> Stream.take_while(fn line -> line != "" end)
      |> Enum.map(fn w ->
        w
        |> String.slice(0..-2)
        |> String.split("{")
        |> then(fn [name, rules] ->
          rules =
            rules
            |> String.split(",")
            |> Stream.map(&String.split(&1, ":"))
            |> Enum.map(fn
              [condition, destination] ->
                # use binary pattern matching
                category =
                  condition
                  |> String.at(0)
                  |> String.to_atom()

                operator =
                  condition
                  |> String.at(1)
                  |> String.to_atom()

                number =
                  condition
                  |> String.slice(2..-1)
                  |> String.to_integer()

                {{category, operator, number}, parse_destination(destination)}

              [destination] ->
                {true, parse_destination(destination)}
            end)

          {String.to_atom(name), rules}
        end)
      end)
      |> Map.new()

    parts =
      input
      |> Stream.drop(map_size(workflows) + 1)
      |> Stream.map(fn part ->
        # validate
        {part, []} = Code.eval_string("%" <> String.replace(part, "=", ": "))
        part
      end)

    {workflows, parts}
  end

  def solve_part_1({workflows, parts}) do
    parts
    |> Stream.filter(fn p ->
      :in
      |> Stream.iterate(fn w ->
        workflows
        |> Map.fetch!(w)
        |> Enum.find(fn
          {{category, operator, number}, _destination} ->
            apply(Kernel, operator, [Map.fetch!(p, category), number])

          {true, _destination} ->
            true
        end)
        |> elem(1)
      end)
      |> Enum.find(&is_boolean/1)
    end)
    |> Stream.map(fn p -> p |> Map.values() |> Enum.sum() end)
    |> Enum.sum()
  end

  defp parse_destination("A"), do: true
  defp parse_destination("R"), do: false
  defp parse_destination(workflow), do: String.to_atom(workflow)
end

System.argv()
|> hd()
|> Aplenty.read_input()
|> Aplenty.solve_part_1()
|> IO.inspect()
