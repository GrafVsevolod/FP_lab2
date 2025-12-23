defmodule Lab2.Impl.SC do
  @moduledoc false

  @type bucket(k, v) :: [{k, v}]
  @type t(k, v) :: %__MODULE__{buckets: [bucket(k, v)], size: non_neg_integer()}

  defstruct buckets: [], size: 0

  @default_cap 64

  @spec new(pos_integer()) :: t(any(), any())
  def new(cap \\ @default_cap) when is_integer(cap) and cap > 0 do
    %__MODULE__{buckets: List.duplicate([], cap), size: 0}
  end

  @spec size(t(any(), any())) :: non_neg_integer()
  def size(%__MODULE__{size: s}), do: s

  @spec get(t(k, v), k) :: {:ok, v} | :error when k: term(), v: term()
  def get(%__MODULE__{} = t, key) do
    {_idx, bucket} = bucket_at(t, key)

    case List.keyfind(bucket, key, 0) do
      {^key, v} -> {:ok, v}
      nil -> :error
    end
  end

  @spec member?(t(k, v), k) :: boolean() when k: term(), v: term()
  def member?(t, key), do: match?({:ok, _}, get(t, key))

  @spec put(t(k, v), k, v) :: t(k, v) when k: term(), v: term()
  def put(%__MODULE__{} = t, key, value) do
    {idx, bucket} = bucket_at(t, key)

    case List.keyfind(bucket, key, 0) do
      nil ->
        new_bucket = [{key, value} | bucket]
        update_bucket(t, idx, new_bucket, +1)

      {^key, _old} ->
        new_bucket = List.keyreplace(bucket, key, 0, {key, value})
        update_bucket(t, idx, new_bucket, 0)
    end
  end

  @spec delete(t(k, v), k) :: t(k, v) when k: term(), v: term()
  def delete(%__MODULE__{} = t, key) do
    {idx, bucket} = bucket_at(t, key)

    case List.keyfind(bucket, key, 0) do
      nil ->
        t

      {^key, _} ->
        new_bucket = List.keydelete(bucket, key, 0)
        update_bucket(t, idx, new_bucket, -1)
    end
  end

  @spec fold(t(k, v), acc, (k, v, acc -> acc)) :: acc when k: term(), v: term(), acc: term()
  def fold(%__MODULE__{buckets: buckets}, acc0, fun) when is_function(fun, 3) do
    Enum.reduce(buckets, acc0, fn bucket, acc ->
      Enum.reduce(bucket, acc, fn {k, v}, acc2 -> fun.(k, v, acc2) end)
    end)
  end

  defp bucket_at(%__MODULE__{buckets: buckets}, key) do
    idx = index_for(key, length(buckets))
    {idx, Enum.at(buckets, idx)}
  end

  defp update_bucket(%__MODULE__{buckets: buckets, size: sz} = t, idx, new_bucket, delta) do
    new_buckets = List.replace_at(buckets, idx, new_bucket)
    %__MODULE__{t | buckets: new_buckets, size: sz + delta}
  end

  defp index_for(key, cap) do
    :erlang.phash2(key, cap)
  end
end
