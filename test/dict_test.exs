defmodule Lab2.DictTest do
  use ExUnit.Case, async: true
  alias Lab2.Dict

  test "put/get/member?/size" do
    d = Dict.new()
    refute Dict.member?(d, :a)

    d = Dict.put(d, :a, 10)
    assert Dict.member?(d, :a)
    assert Dict.get(d, :a) == {:ok, 10}
    assert Dict.size(d) == 1

    d = Dict.put(d, :a, 99)
    assert Dict.size(d) == 1
    assert Dict.get(d, :a) == {:ok, 99}
  end

  test "delete removes key" do
    d = Dict.new() |> Dict.put(:a, 1) |> Dict.put(:b, 2)
    assert Dict.size(d) == 2

    d2 = Dict.delete(d, :a)
    refute Dict.member?(d2, :a)
    assert Dict.member?(d2, :b)
    assert Dict.size(d2) == 1
  end

  test "map transforms values but keeps keys" do
    d = Dict.new() |> Dict.put(:a, 2) |> Dict.put(:b, 3)
    d2 = Dict.map(d, fn _k, v -> v * 10 end)

    assert Dict.get(d2, :a) == {:ok, 20}
    assert Dict.get(d2, :b) == {:ok, 30}
  end

  test "filter keeps only matching entries" do
    d = Dict.new() |> Dict.put(:a, 1) |> Dict.put(:b, 2) |> Dict.put(:c, 3)
    d2 = Dict.filter(d, fn _k, v -> rem(v, 2) == 1 end)

    assert Dict.member?(d2, :a)
    refute Dict.member?(d2, :b)
    assert Dict.member?(d2, :c)
  end

  test "foldl/foldr same sum for commutative op" do
    d = Dict.new() |> Dict.put(:a, 1) |> Dict.put(:b, 2) |> Dict.put(:c, 3)

    s1 = Dict.foldl(d, 0, fn _k, v, acc -> acc + v end)
    s2 = Dict.foldr(d, 0, fn _k, v, acc -> acc + v end)

    assert s1 == 6
    assert s2 == 6
  end
end

