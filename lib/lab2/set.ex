defmodule Lab2.Set do
  @moduledoc """
  Immutable Set built on top of Lab2.Dict.

  Elements are keys; values are irrelevant (always `true`).
  """

  alias Lab2.Dict

  @opaque t(a) :: %__MODULE__{dict: Dict.t(a, true)}
  defstruct dict: Dict.new()

  @spec new() :: t(any())
  def new, do: %__MODULE__{dict: Dict.new()}

  @spec empty() :: t(any())
  def empty, do: new()

  @spec size(t(any())) :: non_neg_integer()
  def size(%__MODULE__{dict: d}), do: Dict.size(d)

  @spec member?(t(a), a) :: boolean() when a: term()
  def member?(%__MODULE__{dict: d}, x), do: Dict.member?(d, x)

  @spec add(t(a), a) :: t(a) when a: term()
  def add(%__MODULE__{dict: d} = s, x) do
    %__MODULE__{s | dict: Dict.put(d, x, true)}
  end

  @spec delete(t(a), a) :: t(a) when a: term()
  def delete(%__MODULE__{dict: d} = s, x) do
    %__MODULE__{s | dict: Dict.delete(d, x)}
  end

  @spec map(t(a), (a -> b)) :: t(b) when a: term(), b: term()
  def map(set, fun) when is_function(fun, 1) do
    foldl(set, new(), fn x, acc -> add(acc, fun.(x)) end)
  end

  @spec filter(t(a), (a -> as_boolean(term()))) :: t(a) when a: term()
  def filter(set, pred) when is_function(pred, 1) do
    foldl(set, new(), fn x, acc -> if pred.(x), do: add(acc, x), else: acc end)
  end

  @spec foldl(t(a), acc, (a, acc -> acc)) :: acc when a: term(), acc: term()
  def foldl(%__MODULE__{dict: d}, acc0, fun) when is_function(fun, 2) do
    Dict.foldl(d, acc0, fn k, _v, acc -> fun.(k, acc) end)
  end

  @spec foldr(t(a), acc, (a, acc -> acc)) :: acc when a: term(), acc: term()
  def foldr(%__MODULE__{dict: d}, acc0, fun) when is_function(fun, 2) do
    Dict.foldr(d, acc0, fn k, _v, acc -> fun.(k, acc) end)
  end

  # ---- Monoid (union) ----
  @spec append(t(a), t(a)) :: t(a) when a: term()
  def append(%__MODULE__{} = a, %__MODULE__{} = b) do
    foldl(b, a, fn x, acc -> add(acc, x) end)
  end

  @spec equal?(t(a), t(a)) :: boolean() when a: term()
  def equal?(a, b) do
    size(a) == size(b) and foldl(a, true, fn x, ok -> ok and member?(b, x) end)
  end

  @spec to_list(t(a)) :: [a] when a: term()
  def to_list(set), do: foldl(set, [], fn x, acc -> [x | acc] end)
end

  defimpl Inspect, for: Lab2.Set do
  import Inspect.Algebra

  def inspect(s, opts) do
    concat(["#Lab2.Set<size=", to_doc(Lab2.Set.size(s), opts), ">"])
  end
end

