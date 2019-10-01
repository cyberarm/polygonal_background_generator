Point = Struct.new(:x, :y)

class Triangle
  def initialize(z, points, colors)
    @z = z

    raise if points.size == 0
    raise if colors.size == 0

    @points = points
    @colors = colors
  end

  def draw
    p1 = @points[0]
    p2 = @points[1]
    p3 = @points[2]

    if @colors.size == @points.size
      Gosu.draw_triangle(
        p1.x, p1.y, @colors[0],
        p2.x, p2.y, @colors[1],
        p3.x, p3.y, @colors[2],
        @z
      )
    else
      Gosu.draw_triangle(
        p1.x, p1.y, @colors.first,
        p2.x, p2.y, @colors.first,
        p3.x, p3.y, @colors.first,
        @z
      )
    end
  end
end