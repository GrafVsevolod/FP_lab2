defmodule Lab2.Dict do
  @moduledoc """
  Immutable Dictionary (key -> value) with a monoid instance.

  Implementation is hidden; API must not leak internals.
  """

  alias Lab2.Impl.SC

  @opaque t(k, v) :: %__MODULE__{impl: SC.t(k, v)}
  defstruct impl: SC.new()

  @spec new() :: t(any(), any())
  def new, do: %__MODULE__{impl: SC.new()}

  @spec empty() :: t(any(), any())
  def empty, do: new()

  @spec size(t(any(), any())) :: non_neg_integer()
  def size(%__MODULE__{impl: impl}), do: SC.size(impl)

  @spec get(t(k, v), k) :: {:ok, v} | :error when k: term(), v: term()
  def get(%__MODULE__{impl: impl}, key), do: SC.get(impl, key)

  @spec member?(t(k, v), k) :: boolean() when k: term(), v: term()
  def member?(%__MODULE__{impl: impl}, key), do: SC.member?(impl, key)

  @spec put(t(k, v), k, v) :: t(k, v) when k: term(), v: term()
  def put(%__MODULE__{impl: impl} = d, key, value) do
    %__MODULE__{d | impl: SC.put(impl, key, value)}
  end

  @spec delete(t(k, v), k) :: t(k, v) when k: term(), v: term()
  def delete(%__MODULE__{impl: impl} = d, key) do
    %__MODULE__{d | impl: SC.delete(impl, key)}
  end

  @spec foldl(t(k, v), acc, (k, v, acc -> acc)) :: acc when k: term(), v: term(), acc: term()
  def foldl(%__MODULE__{impl: impl}, acc0, fun) when is_function(fun, 3) do
    SC.fold(impl, acc0, fun)
  end

  @spec to_list(t(k, v)) :: [{k, v}] when k: term(), v: term()
  def to_list(dict) do
    foldl(dict, [], fn k, v, acc -> [{k, v} | acc] end)
  end

  @spec foldr(t(k, v), acc, (k, v, acc -> acc)) :: acc when k: term(), v: term(), acc: term()
  def foldr(dict, acc0, fun) when is_function(fun, 3) do
    pairs = to_list(dict)
    Enum.reduce(Enum.reverse(pairs), acc0, fn {k, v}, acc -> fun.(k, v, acc) end)
  end

  @spec map(t(k, v), (k, v -> v2)) :: t(k, v2)
        when k: term(), v: term(), v2: term()
  def map(%__MODULE__{} = dict, fun) when is_function(fun, 2) do
    foldl(dict, empty(), fn k, v, acc ->
      put(acc, k, fun.(k, v))
    end)
  end

  @spec filter(t(k, v), (k, v -> as_boolean(term()))) :: t(k, v) when k: term(), v: term()
  def filter(dict, pred) when is_function(pred, 2) do
    foldl(dict, new(), fn k, v, acc ->
      if pred.(k, v), do: put(acc, k, v), else: acc
    end)
  end

  # ---- Monoid ----
  # append is associative, empty is identity.
  # Right-biased on conflicts: values from b overwrite a.
  @spec append(t(k, v), t(k, v)) :: t(k, v) when k: term(), v: term()
  def append(a, b) do
    foldl(b, a, fn k, v, acc -> put(acc, k, v) end)
  end

  @spec equal?(t(k, v), t(k, v)) :: boolean() when k: term(), v: term()
  def equal?(a, b) do
    size(a) == size(b) and
      foldl(a, true, fn k, v, ok ->
        ok and match?({:ok, ^v}, get(b, k))
      end)
  end
end

defimpl Inspect, for: Lab2.Dict do
  import Inspect.Algebra

  def inspect(d, opts) do
    concat(["#Lab2.Dict<size=", to_doc(Lab2.Dict.size(d), opts), ">"])
  end
end
