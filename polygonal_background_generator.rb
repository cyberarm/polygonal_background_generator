begin
  require "gosu"
rescue LoadError
  require_relative "../ffi-gosu/lib/gosu"
end

require_relative "lib/image_data"
require_relative "lib/triangle"

class Window < Gosu::Window
  def initialize
    super(640, 480, resizable: true)
    @window_width, @window_height = 0, 0

    @image = nil
    @image_data = nil
    @scale = 1

    @triangles = []
    @rendered_triangles = nil
  end

  def needs_cursor?; true; end

  def draw
    Gosu.scale(@scale, @scale) do
      @image.draw(0, 0, 1) if @image
      @rendered_triangles.draw(0,0,2) if @rendered_triangles && !Gosu.button_down?(Gosu::KB_Z)
    end
  end

  def update
    if window_resized?
      recalculate if @image
      @window_width = self.width
      @window_height = self.height
    end
  end

  def window_resized?
    @window_width != self.width || @window_height != self.height
  end

  def drop(filename)
    pp filename
    @image = Gosu::Image.new(filename)
    pp :loaded_image
    @image_data = ImageData.new(@image)
    pp :loaded_image_data
    recalculate
    pp :got_scale
    sample_image
    pp :complete
  end

  def no_remainder?(decimal)
    decimal.to_s.split(".").last.to_i == 0
  end

  def recalculate
    @scale = [self.width / @image.width.to_f, self.height / @image.height.to_f].min
  end

  def sample_image
    _color = @image_data.at(0, 0)

    # checking = 3
    # results = []
    # @image.width.times do
    #   if no_remainder?(@image.width.to_f / checking) && no_remainder?(@image.height.to_f / checking)
    #     results << checking
    #   end

    #   checking += 1
    # end

    # pp results

    # return if results.empty?

    @triangles.clear
    tile_size = Integer(ARGV[0])
    puts "Using: #{tile_size} tile size"
    quarter_tile = (tile_size / 4)

    (@image.height / tile_size).times do |y|
      (@image.width / tile_size).times do |x|
        t1_points = []
        t2_points = []

        if y.even?
          t1_color = sample_color(x * tile_size + quarter_tile,     y * tile_size + quarter_tile,     tile_size)
          t2_color = sample_color(x * tile_size + quarter_tile * 3, y * tile_size + quarter_tile * 3, tile_size)

          shared_top    = Point.new(x * tile_size + tile_size, y * tile_size)
          shared_bottom = Point.new(x * tile_size, y * tile_size + tile_size)

          t1_points.push(Point.new(x * tile_size, y * tile_size), shared_top, shared_bottom)
          t2_points.push(shared_top, Point.new(x * tile_size + tile_size, y * tile_size + tile_size), shared_bottom)
        else
          t1_color = sample_color(x * tile_size + quarter_tile * 3, y * tile_size + quarter_tile,     tile_size)
          t2_color = sample_color(x * tile_size + quarter_tile,     y * tile_size + quarter_tile * 3, tile_size)

          shared_top    = Point.new(x * tile_size, y * tile_size)
          shared_bottom = Point.new(x * tile_size + tile_size, y * tile_size + tile_size)

          t1_points.push(shared_top, Point.new(x * tile_size + tile_size, y * tile_size), shared_bottom)
          t2_points.push(shared_top, shared_bottom, Point.new(x * tile_size, y * tile_size + tile_size))
        end


        @triangles << Triangle.new(2, t1_points, [t1_color])
        @triangles << Triangle.new(2, t2_points, [t2_color])
      end
    end

    @rendered_triangles = Gosu.render(@image.width, @image.height) do
      @triangles.each(&:draw)
    end
  end

  def sample_color(x, y, tile_size)
    colors = []

    colors << @image_data.at(x, y)
    colors << @image_data.at(x - 2, y)
    colors << @image_data.at(x - 2, y - 2)
    colors << @image_data.at(x + 2, y)
    colors << @image_data.at(x + 2, y + 2)

    averge_color(colors.compact)
  end

  def averge_color(colors)
    red, green, blue = 0, 0, 0

    colors.each do |color|
      red   += color.red
      green += color.green
      blue  += color.blue
    end

    red   /= colors.size
    green /= colors.size
    blue  /= colors.size

    Gosu::Color.new(255, red, green, blue)
  end

  def button_up(id)
    if id == Gosu::KB_S
      @rendered_triangles.save("data/render-#{Time.now.to_i}.png") if @rendered_triangles
    end
  end
end

Window.new.show