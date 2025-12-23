defmodule Lab2.SetTest do
  use ExUnit.Case, async: true
  alias Lab2.Set

  test "add/member?/size/delete" do
    s = Set.new()
    refute Set.member?(s, 1)

    s = s |> Set.add(1) |> Set.add(2) |> Set.add(2)
    assert Set.size(s) == 2
    assert Set.member?(s, 2)

    s2 = Set.delete(s, 2)
    refute Set.member?(s2, 2)
    assert Set.size(s2) == 1
  end

  test "map" do
    s = Set.new() |> Set.add(1) |> Set.add(2)
    s2 = Set.map(s, &(&1 * 10))
    assert Set.member?(s2, 10)
    assert Set.member?(s2, 20)
  end

  test "filter" do
    s = Set.new() |> Set.add(1) |> Set.add(2) |> Set.add(3)
    s2 = Set.filter(s, fn x -> rem(x, 2) == 1 end)
    assert Set.member?(s2, 1)
    assert Set.member?(s2, 3)
    refute Set.member?(s2, 2)
  end
end
