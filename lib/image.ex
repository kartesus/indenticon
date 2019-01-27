defmodule Identicon.Image do
  defstruct [:input, :hex, :color, :grid, :filled, :pixels]
  def new(input), do: %Identicon.Image{input: input}
end
