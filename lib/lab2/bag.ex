defmodule Lab2.Bag do
  @moduledoc """
  Immutable Bag (multiset) built on top of Lab2.Dict.

  Stores element -> count (positive integer).
  """

  alias Lab2.Dict

  @opaque t(a) :: %__MODULE__{dict: Dict.t(a, pos_integer())}
  defstruct dict: Dict.new()

  @spec new() :: t(any())
  def new, do: %__MODULE__{dict: Dict.new()}

  @spec empty() :: t(any())
  def empty, do: new()

  @spec size(t(any())) :: non_neg_integer()
  def size(%__MODULE__{dict: d}) do
    Dict.foldl(d, 0, fn _k, cnt, acc -> acc + cnt end)
  end

  @spec count(t(a), a) :: non_neg_integer() when a: term()
  def count(%__MODULE__{dict: d}, x) do
    case Dict.get(d, x) do
      {:ok, c} -> c
      :error -> 0
    end
  end

  @spec add(t(a), a, pos_integer()) :: t(a) when a: term()
  def add(%__MODULE__{dict: d} = b, x, n \\ 1) when is_integer(n) and n > 0 do
    new_cnt = count(b, x) + n
    %__MODULE__{b | dict: Dict.put(d, x, new_cnt)}
  end

  @spec delete(t(a), a, pos_integer()) :: t(a) when a: term()
  def delete(%__MODULE__{dict: d} = b, x, n \\ 1) when is_integer(n) and n > 0 do
    cur = count(b, x)

    cond do
      cur == 0 ->
        b

      cur <= n ->
        %__MODULE__{b | dict: Dict.delete(d, x)}

      true ->
        %__MODULE__{b | dict: Dict.put(d, x, cur - n)}
    end
  end

  @spec filter(t(a), (a, pos_integer() -> as_boolean(term()))) :: t(a) when a: term()
  def filter(%__MODULE__{dict: d}, pred) when is_function(pred, 2) do
    Dict.filter(d, pred) |> wrap()
  end

  @spec map(t(a), (a, pos_integer() -> {b, pos_integer()})) :: t(b)
        when a: term(), b: term()
  def map(%__MODULE__{dict: d}, fun) when is_function(fun, 2) do
    Dict.foldl(d, new(), fn k, cnt, acc ->
      {k2, cnt2} = fun.(k, cnt)
      add(acc, k2, cnt2)
    end)
  end

  @spec foldl(t(a), acc, (a, pos_integer(), acc -> acc)) :: acc when a: term(), acc: term()
  def foldl(%__MODULE__{dict: d}, acc0, fun) when is_function(fun, 3) do
    Dict.foldl(d, acc0, fun)
  end

  @spec foldr(t(a), acc, (a, pos_integer(), acc -> acc)) :: acc when a: term(), acc: term()
  def foldr(%__MODULE__{dict: d}, acc0, fun) when is_function(fun, 3) do
    Dict.foldr(d, acc0, fun)
  end

  # ---- Monoid (merge by summing counts) ----
  @spec append(t(a), t(a)) :: t(a) when a: term()
  def append(%__MODULE__{} = a, %__MODULE__{} = b) do
    foldl(b, a, fn k, cnt, acc -> add(acc, k, cnt) end)
  end

  @spec equal?(t(a), t(a)) :: boolean() when a: term()
  def equal?(a, b), do: Dict.equal?(unwrap(a), unwrap(b))

  defp wrap(d), do: %__MODULE__{dict: d}
  defp unwrap(%__MODULE__{dict: d}), do: d
end

  defimpl Inspect, for: Lab2.Bag do
  import Inspect.Algebra

  def inspect(b, opts) do
    concat(["#Lab2.Bag<size=", to_doc(Lab2.Bag.size(b), opts), ">"])
  end
end

