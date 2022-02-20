module GosuGameJam2
  class Point
    attr_accessor :x, :y, :z

    def initialize(x, y, z = 0)
      @x = x
      @y = y
      @z = z
    end

    def +(other)
      raise "can't add point to #{other}" unless other.is_a?(Point)
      Point.new(x + other.x, y + other.y, z + other.z)
    end 
  end
end
