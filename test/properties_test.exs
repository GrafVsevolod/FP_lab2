defmodule Lab2.PropertiesTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Lab2.Dict
  alias Lab2.Set
  alias Lab2.Bag

  defp dict_from_kvs(kvs) do
    Enum.reduce(kvs, Dict.new(), fn {k, v}, acc -> Dict.put(acc, k, v) end)
  end

  defp set_from_list(xs) do
    Enum.reduce(xs, Set.new(), fn x, acc -> Set.add(acc, x) end)
  end

  defp bag_from_pairs(pairs) do
    Enum.reduce(pairs, Bag.new(), fn {k, n}, acc -> Bag.add(acc, k, n) end)
  end

  defp gen_key do
    one_of([integer(), atom(:alphanumeric), binary(min_length: 0, max_length: 10)])
  end

  defp gen_val do
    one_of([integer(), binary(min_length: 0, max_length: 10)])
  end

  defp gen_dict do
    uniq_list_of({gen_key(), gen_val()}, max_length: 30, by: fn {k, _v} -> k end)
    |> map(&dict_from_kvs/1)
  end

  defp gen_set do
    list_of(gen_key(), max_length: 30)
    |> map(&set_from_list/1)
  end

  defp gen_bag do
    list_of({gen_key(), positive_integer()}, max_length: 30)
    |> map(&bag_from_pairs/1)
  end

  property "Dict monoid: identity" do
    check all(d <- gen_dict()) do
      e = Dict.empty()
      assert Dict.equal?(Dict.append(e, d), d)
      assert Dict.equal?(Dict.append(d, e), d)
    end
  end

  property "Dict monoid: associativity" do
    check all(a <- gen_dict(), b <- gen_dict(), c <- gen_dict()) do
      left = Dict.append(Dict.append(a, b), c)
      right = Dict.append(a, Dict.append(b, c))
      assert Dict.equal?(left, right)
    end
  end

  property "Set monoid: identity + associativity" do
    check all(a <- gen_set(), b <- gen_set(), c <- gen_set()) do
      e = Set.empty()
      assert Set.equal?(Set.append(e, a), a)
      assert Set.equal?(Set.append(a, e), a)

      left = Set.append(Set.append(a, b), c)
      right = Set.append(a, Set.append(b, c))
      assert Set.equal?(left, right)
    end
  end

  property "Bag monoid: identity + associativity" do
    check all(a <- gen_bag(), b <- gen_bag(), c <- gen_bag()) do
      e = Bag.empty()
      assert Bag.equal?(Bag.append(e, a), a)
      assert Bag.equal?(Bag.append(a, e), a)

      left = Bag.append(Bag.append(a, b), c)
      right = Bag.append(a, Bag.append(b, c))
      assert Bag.equal?(left, right)
    end
  end

  property "Dict: put then get returns that value" do
    check all(d <- gen_dict(), k <- gen_key(), v <- gen_val()) do
      d2 = Dict.put(d, k, v)
      assert Dict.get(d2, k) == {:ok, v}
    end
  end
end
