require_relative '../engine/entity'

module GosuGameJam2
  # A trail left by the effect of a tower. 
  class ProjectileTrail
    def initialize(from:, to:, colour:, opacity:, explosion: nil)
      @from = from
      @to = to
      @colour = colour
      @thickness = thickness
      @opacity = opacity
      @explosion = explosion
    end

    attr_accessor :from
    attr_accessor :to
    attr_accessor :colour
    attr_accessor :thickness
    attr_accessor :opacity
    attr_accessor :explosion

    def tick
      self.opacity -= 15
      $world.entities.delete(self) if opacity <= 0
    end

    def draw
      c = Gosu::Color.argb(opacity, colour.red, colour.green, colour.blue)
      Gosu.draw_line(from.x, from.y, c, to.x, to.y, c)

    if explosion
        # TODO: should be filled ideally
        Gosu::draw_circle(to.x, to.y, explosion, c)
      end
    end
  end
end
