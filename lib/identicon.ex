defmodule Identicon do
  def for(input) do
    Identicon.Image.new(input)
    |> hash()
    |> pick_color()
    |> build_grid()
    |> filter_odd_squares()
    |> build_pixel_map()
    |> draw_image()
    |> save(input)
  end

  def hash(image) do
    hex = :crypto.hash(:md5, image.input) |> :binary.bin_to_list()
    %{image | hex: hex}
  end

  def pick_color(image) do
    [r, g, b] = Enum.take(image.hex, 3)
    %{image | color: {r, g, b}}
  end

  def build_grid(image) do
    grid =
      image.hex
      |> Enum.chunk_every(3, 3, :discard)
      |> Enum.map(&mirror_row/1)
      |> List.flatten()
      |> Enum.with_index()

    %{image | grid: grid}
  end

  def filter_odd_squares(image) do
    filled =
      image.grid
      |> Enum.filter(fn {code, _index} -> rem(code, 2) == 0 end)
      |> Enum.map(fn {_code, index} -> index end)

    %{image | filled: filled}
  end

  def build_pixel_map(image) do
    pixels =
      Enum.map(image.filled, fn i ->
        horizontal = rem(i, 5) * 50
        vertical = div(i, 5) * 50

        top_left = {horizontal + 25, vertical + 25}
        bottom_right = {horizontal + 75, vertical + 75}
        {top_left, bottom_right}
      end)

    %{image | pixels: pixels}
  end

  def draw_image(%{color: color, pixels: pixels}) do
    image = :egd.create(300, 300)
    fill = :egd.color(color)

    Enum.each(pixels, fn {start, stop} ->
      :egd.filledRectangle(image, start, stop, fill)
    end)

    :egd.render(image)
  end

  def save(image, filename) do
    File.write("#{filename}.png", image)
  end

  defp mirror_row([a, b, c]), do: [a, b, c, b, a]
end
