defmodule ExConcepts.LensTest do
  use ExUnit.Case
  alias ExConcepts.Lens

  setup do
    %{
      firstName: "Bob",
      surname: "The",
      occupation: "Builder",
      address: %{
        number: 10,
        street: "Downing St",
        city: "London",
      },
    }
  end

  test "that you can view a cell", subject do
    surname = Lens.from(:surname)

    assert Lens.view(subject, surname) == "The"
  end

  test "that you can view a nested cell", subject do
    address = Lens.from(:address)
    street = Lens.from(:street)

    address_street = Lens.concat(address, street)

    assert "Downing St" = Lens.view(subject, address_street)
  end

  test "that you can create a concated list", subject do
    lens = Lens.from([:address, :street])
    assert "Downing St" == Lens.view(subject, lens)
    assert 4 == Lens.view(Lens.set(subject, 4, lens), lens)
  end

  test "that you can set a cell", subject do
    surname = Lens.from(:surname)

    assert %{
      firstName: "Bob",
      surname: "The-Second",
      occupation: "Builder",
      address: %{
        number: 10,
        street: "Downing St",
        city: "London",
      },
    } = Lens.set(subject, "The-Second", surname)
  end

  test "that you can set a nested cell", subject do
    address = Lens.from(:address)
    street = Lens.from(:number)

    address_street = Lens.concat(address, street)

    assert %{
      firstName: "Bob",
      surname: "The",
      occupation: "Builder",
      address: %{
        number: 45,
        street: "Downing St",
        city: "London",
      },
    } = Lens.set(subject, 45, address_street)
  end

  test "that you can over a cell", subject do
    surname = Lens.from(:surname)

    assert %{
      firstName: "Bob",
      surname: "THE",
      occupation: "Builder",
      address: %{
        number: 10,
        street: "Downing St",
        city: "London",
      },
    } = Lens.over(subject, &String.upcase/1, surname)
  end

  test "that you can over a nested cell", subject do
    address = Lens.from(:address)
    street = Lens.from(:street)

    address_street = Lens.concat(address, street)

    assert %{
      firstName: "Bob",
      surname: "The",
      occupation: "Builder",
      address: %{
        number: 10,
        street: "DOWNING ST",
        city: "London",
      },
    } = Lens.over(subject, &String.upcase/1, address_street)
  end

  test "that you can view an array index" do
    l2 = Lens.fromIdx(1)
    assert 2 = Lens.view([1, 2, 3, 4], l2)
  end

  test "that you can set an array index" do
    l2 = Lens.fromIdx(1)
    assert [1, 12, 3, 4] = Lens.set([1, 2, 3, 4], 12, l2)
  end

  test "that you can over an array index" do
    l2 = Lens.fromIdx(1)
    assert [1, 4, 3, 4] = Lens.over([1, 2, 3, 4], &(&1 * 2), l2)
  end

  test "that you can modify the getter", subject do
    makeName = fn %{ firstName: fname, surname: sname } = obj -> Map.merge(obj, %{ name: fname <> " " <> sname }) end
    l1 = Lens.fromIdx(0)
    name = Lens.from(:name)
    assert "Bob The" =
      l1
      |> Lens.fmap(makeName)
      |> Lens.concat(name)
      |> Lens.fview([subject])
  end

  test "that contramap does what we expect", subject do
    makeList = fn a -> [a, a, a] end
    second = Lens.fromIdx(1)
    address = Lens.from(:address)
    sa = subject.address
    assert %{address: [^sa, 1, ^sa] } =
      second
      |> Lens.fcontramap(makeList)
      |> Lens.fconcat(address)
      |> Lens.fset(subject, 1)
  end

  test "that you can modify the setter", subject do
    makeApartment = fn %{ number: number } = obj -> Map.merge(obj, %{ number: "Unit 4 / #{inspect number}" }) end
    retired = &(&1 <> " - retired")

    address = Lens.from(:address)
    occupation = Lens.from(:occupation)

    result = subject
      |> Lens.over(
        retired,
        occupation
      )
      |> IO.inspect
      |> Lens.over(&(&1),
        Lens.map(makeApartment, address)
      )
    assert %{
      firstName: "Bob",
      surname: "The",
      occupation: "Builder - retired",
      address: %{
        number: "Unit 4 / 10",
        street: "Downing St",
        city: "London",
      },
    } = result
  end
end
