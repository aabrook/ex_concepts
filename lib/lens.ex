defmodule ExConcepts.Lens do
  def from([h | t]), do: Enum.reduce(t, from(h), &(concat(&2, from(&1))))
  def from([h]), do: from(h)
  def from(a) do
    {
      fn obj -> Map.get(obj, a) end,
      fn obj, val -> Map.put(obj, a, val) end
    }
  end

  def fromIdx(i) do
    {
      fn obj -> Enum.at(obj, i) end,
      fn obj, val ->
        {l, [_h | t]} = Enum.split(obj, i)
        l ++ [val] ++ t
      end
    }
  end

  def empty() do
    {
      fn obj -> obj end,
      fn _, val -> val end
    }
  end

  def view(obj, {get, _}), do: get.(obj)
  def view({get, _}, obj), do: get.(obj)
  def set({_, _} = lens, obj, val), do: set(obj, val, lens)
  def set(obj, val, lens), do: over(obj, fn _ -> val end, lens)
  def over({_, _} = lens, obj, setter), do: over(obj, setter, lens)
  def over(obj, setter, {get, set}), do: set.(obj, setter.(get.(obj)))

  def fview({get, _}, obj), do: get.(obj)
  def fset(lens, obj, val), do: set(obj, val, lens)
  def fover(lens, obj, setter), do: over(obj, setter, lens)

  def fconcat(a, b), do: concat(b, a)
  def concat({l_get, l_set}, {r_get, r_set}) do
    {
      fn obj -> r_get.(l_get.(obj)) end,
      fn obj, val -> l_set.(obj, r_set.(l_get.(obj), val)) end
    }
  end

  def fcontramap(lens, f), do: contramap(f, lens)
  def contramap(f, {get, set}) do
    {
      fn obj -> get.(f.(obj)) end,
      fn obj, val -> set.(f.(obj), val) end
    }
  end

  def dimap(f, g, {get, set}) do
    {
      fn obj -> f.(get.(obj)) end,
      fn obj, val -> g.(set.(obj, val)) end
    }
  end

  def fmap(lens, f), do: map(f, lens)
  def map({_, _} = lens, f), do: map(f, lens)
  def map(f, {get, set}) do
    {
      fn obj -> f.(get.(obj)) end,
      set
    }
  end
end

