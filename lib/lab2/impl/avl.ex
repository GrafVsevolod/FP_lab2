defmodule Lab2.Impl.AVL do
  @moduledoc false

  defstruct root: nil, size: 0

  defmodule Node do
    @moduledoc false
    defstruct key: nil, val: nil, h: 1, left: nil, right: nil
  end

  @type t(k, v) :: %__MODULE__{root: node(k, v) | nil, size: non_neg_integer()}
  @type node(k, v) :: %Node{key: k, val: v, h: pos_integer(), left: node(k, v) | nil, right: node(k, v) | nil}

  # --- public-ish ops used by Dict ---
  def new, do: %__MODULE__{}

  def size(%__MODULE__{size: s}), do: s

  def get(%__MODULE__{root: r}, key) do
    case find(r, key) do
      nil -> :error
      %Node{val: v} -> {:ok, v}
    end
  end

  def has_key?(t, key), do: match?({:ok, _}, get(t, key))

  def put(%__MODULE__{} = t, key, val) do
    {new_root, inserted?} = insert(t.root, key, val)
    %__MODULE__{t | root: new_root, size: t.size + if(inserted?, do: 1, else: 0)}
  end

  def delete(%__MODULE__{} = t, key) do
    {new_root, deleted?} = remove(t.root, key)
    %__MODULE__{t | root: new_root, size: t.size - if(deleted?, do: 1, else: 0)}
  end

  # fold in-order (sorted by term order)
  def foldl(%__MODULE__{root: r}, acc, fun), do: fold_inorder(r, acc, fun)
  def foldr(%__MODULE__{root: r}, acc, fun), do: fold_revorder(r, acc, fun)

  # --- helpers: compare keys ---
  defp cmp(a, b), do: :erlang.compare(a, b)

  # --- find ---
  defp find(nil, _k), do: nil
  defp find(%Node{key: k} = n, key) do
    case cmp(key, k) do
      :lt -> find(n.left, key)
      :gt -> find(n.right, key)
      :eq -> n
    end
  end

  # --- height/balance ---
  defp h(nil), do: 0
  defp h(%Node{h: hh}), do: hh
  defp upd_h(%Node{} = n), do: %Node{n | h: 1 + max(h(n.left), h(n.right))}
  defp bf(%Node{} = n), do: h(n.left) - h(n.right)

  # rotations
  defp rot_right(%Node{left: %Node{left: x2, right: y2} = x} = y) do
    new_right = upd_h(%Node{y | left: y2})
    upd_h(%Node{x | right: new_right})
  end

  defp rot_left(%Node{right: %Node{left: x2, right: y2} = y} = x) do
    new_left = upd_h(%Node{x | right: x2})
    upd_h(%Node{y | left: new_left})
  end

  defp rebalance(%Node{} = n0) do
    n = upd_h(n0)
    case bf(n) do
      b when b > 1 ->
        # left heavy
        if bf(n.left) < 0 do
          # LR
          rot_right(%Node{n | left: rot_left(n.left)})
        else
          # LL
          rot_right(n)
        end

      b when b < -1 ->
        # right heavy
        if bf(n.right) > 0 do
          # RL
          rot_left(%Node{n | right: rot_right(n.right)})
        else
          # RR
          rot_left(n)
        end

      _ ->
        n
    end
  end

  # --- insert ---
  defp insert(nil, key, val), do: {%Node{key: key, val: val}, true}

  defp insert(%Node{key: k} = n, key, val) do
    case cmp(key, k) do
      :lt ->
        {l, ins?} = insert(n.left, key, val)
        {rebalance(%Node{n | left: l}), ins?}

      :gt ->
        {r, ins?} = insert(n.right, key, val)
        {rebalance(%Node{n | right: r}), ins?}

      :eq ->
        {upd_h(%Node{n | val: val}), false}
    end
  end

  # --- remove ---
  defp remove(nil, _key), do: {nil, false}

  defp remove(%Node{key: k} = n, key) do
    case cmp(key, k) do
      :lt ->
        {l, del?} = remove(n.left, key)
        {rebalance(%Node{n | left: l}), del?}

      :gt ->
        {r, del?} = remove(n.right, key)
        {rebalance(%Node{n | right: r}), del?}

      :eq ->
        # delete this node
        {delete_node(n), true}
    end
  end

  defp delete_node(%Node{left: nil, right: r}), do: r
  defp delete_node(%Node{left: l, right: nil}), do: l
  defp delete_node(%Node{} = n) do
    # replace with inorder successor (min from right)
    {%Node{} = succ, new_right} = pop_min(n.right)
    rebalance(%Node{succ | left: n.left, right: new_right})
  end

  defp pop_min(%Node{left: nil} = n), do: {n, n.right}
  defp pop_min(%Node{} = n) do
    {m, new_left} = pop_min(n.left)
    {m, rebalance(%Node{n | left: new_left})}
  end

  # --- folds ---
  defp fold_inorder(nil, acc, _fun), do: acc
  defp fold_inorder(%Node{} = n, acc, fun) do
    acc = fold_inorder(n.left, acc, fun)
    acc = fun.(n.key, n.val, acc)
    fold_inorder(n.right, acc, fun)
  end

  defp fold_revorder(nil, acc, _fun), do: acc
  defp fold_revorder(%Node{} = n, acc, fun) do
    acc = fold_revorder(n.right, acc, fun)
    acc = fun.(n.key, n.val, acc)
    fold_revorder(n.left, acc, fun)
  end
end
