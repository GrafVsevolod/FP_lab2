defmodule Lab2.BagTest do
  use ExUnit.Case, async: true
  alias Lab2.Bag

  test "add/count/size/delete" do
    b = Bag.new()
    assert Bag.count(b, "a") == 0

    b = b |> Bag.add("a") |> Bag.add("a", 2) |> Bag.add("b", 5)
    assert Bag.count(b, "a") == 3
    assert Bag.count(b, "b") == 5
    assert Bag.size(b) == 8

    b2 = Bag.delete(b, "a", 2)
    assert Bag.count(b2, "a") == 1
    assert Bag.size(b2) == 6

    b3 = Bag.delete(b2, "a", 10)
    assert Bag.count(b3, "a") == 0
  end
end
