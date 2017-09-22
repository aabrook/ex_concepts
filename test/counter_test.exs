defmodule ExConcepts.CounterTest do
  use ExUnit.Case
  alias ExConcepts.Lens

  setup do
    %{
      state: %{
        nested: %{
          deeply_nested: %{
            tally: 0
          },
          tally: 0
        },
        tally: 0
      }
    }
  end

  defp inc_tally(lens, state) do
    tally_lens = Lens.concat(lens, Lens.from(:tally))

    Lens.over(state, &(&1 + 1), tally_lens)
  end

  test "it can view a deeply nested entry", %{ state: state } do
    deep_view =
      :nested
      |> Lens.from
      |> Lens.concat(Lens.from(:deeply_nested))
      |> Lens.concat(Lens.from(:tally))
      |> Lens.view(state)

    assert deep_view == 0
  end

  test "it can set a deeply nested entry", %{ state: state } do
    deep_set =
      :nested
      |> Lens.from
      |> Lens.concat(Lens.from(:deeply_nested))
      |> Lens.concat(Lens.from(:tally))

    result = Lens.set(state, 5, deep_set)

    assert result == %{
        nested: %{
          deeply_nested: %{
            tally: 5
          },
          tally: 0
        },
        tally: 0
      }
  end

  test "it should update deeply nested entries", %{ state: state } do
    result = :nested
      |> Lens.from
      |> Lens.concat(Lens.from(:deeply_nested))
      |> inc_tally(state)

    assert result == %{
      nested: %{
        deeply_nested: %{
          tally: 1
        },
        tally: 0
      },
      tally: 0
    }
  end

  test "it should update nested entries", %{ state: state } do
    result = :nested
      |> Lens.from
      |> inc_tally(state)

    assert result == %{
      nested: %{
        deeply_nested: %{
          tally: 0
        },
        tally: 1
      },
      tally: 0
    }
  end

  test "it should update root entries", %{ state: state } do
    result = inc_tally(Lens.empty(), state)

    assert result == %{
      nested: %{
        deeply_nested: %{
          tally: 0
        },
        tally: 0
      },
      tally: 1
    }
  end

  test "traverse through state and update each tally", %{ state: state } do
    deeply_nested = fn lens, state ->
      lens
      |> Lens.concat(Lens.from(:deeply_nested))
      |> inc_tally(state)
    end
    nested = fn lens, state ->
      nested_lens = lens
      |> Lens.concat(Lens.from(:nested))

      nested_lens
      |> deeply_nested.(state)
      |> Lens.over(&(Map.merge(&1, %{ insert_prop: "props" })), nested_lens)
    end
    root = fn lens, state ->
      nested.(lens, inc_tally(lens, state))
    end

    assert root.(Lens.empty(), state) == %{
      nested: %{
        deeply_nested: %{
          tally: 1
        },
        tally: 0,
        insert_prop: "props"
      },
      tally: 1
    }
  end

  test "traverse through state with map and update each tally", %{ state: state } do
    deeply_nested = fn lens, state ->
      lens
      |> Lens.concat(Lens.from(:deeply_nested))
      |> inc_tally(state)
    end
    nested = fn lens, state ->
      nested_lens = lens
      |> Lens.concat(Lens.from(:nested))
      |> Lens.map(&(Map.merge(&1, %{ insert_prop: "props" })))
      |> deeply_nested.(state)
    end
    root = fn lens, state ->
      nested.(lens, inc_tally(lens, state))
    end

    assert root.(Lens.empty(), state) == %{
      nested: %{
        deeply_nested: %{
          tally: 1
        },
        tally: 0,
        insert_prop: "props"
      },
      tally: 1
    }
  end
end
