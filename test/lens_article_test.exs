defmodule ExConcepts.LensArticleTest do
  use ExUnit.Case
  alias ExConcepts.Lens

  def transform_address(%{ full_address: full_address }) do
    [number | address] =
      full_address
      |> String.split

    %{
      number: number,
      street: Enum.join(address, " "),
      full_address: full_address
    }
  end
  def transform_address(%{ street: street, number: number }) do
    %{
      number: number,
      street: street,
      full_address: "#{number} #{street}"
    }
  end

  def neighbours(street) do
    # Example data but you'd likely use a query to retrieve this
    [
      %{
        full_name: "Jim Jimerson",
        age: 78,
        address: %{
          number: 14,
          street: street
        }
      },
    %{
      full_name: "Don McDonson",
      age: 23,
      address: %{
        number: 16,
        street: street
      }
    }
  ]
  end

  def get_street do
    Lens.from(:address)
    |> Lens.fmap(&transform_address/1)
    |> Lens.concat(Lens.from(:street))
  end

  def get_neighbours(person) do
    address =
      Lens.from([:address, :neighbours])

    neighbours =
      person
      |> Lens.view(get_street)
      |> neighbours

    IO.puts "-------------------------------"
    person
    |> Lens.over(&String.upcase/1, get_street)
    |> IO.inspect

    Enum.map(neighbours, fn n -> Lens.over(n, &String.upcase/1, get_street) end)
    |> IO.inspect
    IO.puts "-------------------------------"

    person
    |> Lens.set(neighbours, address)
  end

  test "get_neighbours" do
    p = %{ address: %{ full_address: "12 Downing Street" } }

    lenser = p
    |> get_neighbours
    |> Lens.view(Lens.from(:address))
    |> IO.inspect

    IO.puts "-------------------------------"

    inner = p
    |> get_in_neighbours
    |> get_in([:address])
    |> IO.inspect

    assert lenser == inner
  end

  def get_in_street do
    [
      :address,
      fn (:get, data, next) ->
        data
        |> transform_address
        |> next.()
      end,
      :street
    ]
  end
  def get_in_neighbours(person) do
    neighbours =
      person
      |> get_in(get_in_street)
      |> neighbours

    person
    |> update_in([:address], &Map.merge(&1, %{ neighbours: neighbours }))
  end
end
