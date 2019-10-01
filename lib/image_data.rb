class ImageData
  def initialize(image)
    @width = image.width
    @height = image.height

    @bytes = image.to_blob.bytes
  end

  def at(x, y)
    index = (x + @width * y) * 4
    r, g, b, a = @bytes[index, 4]
    if index < @bytes.size
      Gosu::Color.new(a.ord, r.ord, g.ord, b.ord)
    else
      nil
      #raise "Error: Wrapping around!\n #{x}:#{y} -> #{index} (#{@bytes.size})"
    end
  end

  def set(x, y, color)
    @data[x * @width + y] = color
  end
end