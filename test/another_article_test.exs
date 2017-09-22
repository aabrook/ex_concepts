defmodule ExConcepts.AnotherArticleTest do
  use ExUnit.Case
  alias ExConcepts.Lens

  setup do
    %{
      data: [
        %{
          firstName: "John",
          surname: "Johanson",
          age: 27,
          address: %{
            postal_address: %{
              full_address: "43 Jonson Boulavarde"
            },
            street_address: %{
              full_address: "43 Jonson Boulavarde"
            }
          }
        },
        %{
          firstName: "Meg",
          surname: "Meggerson",
          age: 23,
          address: %{
            postal_address: %{
              full_address: "12 Downing Street"
            },
            street_address: %{
              full_address: "12 Downing Street"
            }
          }
        }
      ]
    }
  end

  def neighbours(street_name) do
    # Example data but you'd likely use a query to retrieve this
    [
      %{
        full_name: "Jim Jimerson",
        age: 78,
        address: %{
          number: 14,
          street: street_name
        }
      },
      %{
        full_name: "Don McDonson",
        age: 23,
        address: %{
          number: 16,
          street: street_name
        }
      }
    ]
  end

  def find_street(%{ full_address: full_address }) do
    [number | street] = full_address
      |> String.split(" ")

    %{
      full_address: full_address,
      number: number,
      street: Enum.join(street, " ")
    }
  end

  def add_neighbours(person) do
    address_lens = Lens.from(:address)
    street_lens = Lens.concat(address_lens, Lens.from(:street_address))
    postal_lens = Lens.concat(address_lens, Lens.from(:postal_address))

    neighbours =
      postal_lens
      |> Lens.map(&find_street/1)
      |> Lens.concat(Lens.from(:street))
      |> Lens.view(person)
      |> neighbours()

    street_lens
    |> Lens.concat(Lens.from(:neighbours))
    |> Lens.set(person, neighbours)
  end

  def all_neighbours(people) do
    Enum.map(people, &add_neighbours/1)
  end

  test "that we can get all the neighbours from our source data", %{ data: people } do
    result =
      people
      |> all_neighbours

    assert result = [
      %{
        firstName: "John",
        surname: "Johanson",
        age: 27,
        address: %{
          postal_address: %{
            full_address: "43 Jonson Boulavarde"
          },
          street_address: %{
            full_address: "43 Jonson Boulavarde",
            neighbours: [
              %{
                address: %{number: 14, street: "Jonson Boulavarde"},
                age: 78,
                full_name: "Jim Jimerson"
              },
              %{
                address: %{number: 16, street: "Jonson Boulavarde"},
                age: 23,
                full_name: "Don McDonson"
              }
            ]
          }
        }
      },
      %{
        firstName: "Meg",
        surname: "Meggerson",
        age: 23,
        address: %{
          postal_address: %{full_address: "12 Downing Street"},
          street_address: %{
            full_address: "12 Downing Street",
            neighbours: [
              %{
                address: %{number: 14, street: "Downing Street"},
                age: 78,
                full_name: "Jim Jimerson"
              },
              %{
                address: %{number: 16, street: "Downing Street"},
                age: 23,
                full_name: "Don McDonson"
              }
            ]
          }
        }
      }
    ]
  end
end
