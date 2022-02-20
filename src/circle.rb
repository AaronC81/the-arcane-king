# Modified from: https://gist.github.com/runnerpack/00679010f2ab76696031952f1b7f354a
# The linked algorithm is really slow - this records every circle draw and reuses it later!

require 'gosu'

$rendered_circles = {}

module Gosu

  def self.draw_circle(x, y, r, c, z = 0, thickness = 1, sides = nil, mode = :default)
    if $rendered_circles[[r, c, thickness]]
      $rendered_circles[[r, c, thickness]].draw(x, y, z)
    else
      $rendered_circles[[r, c, thickness]] = Gosu.record(r * 2 + thickness * 2, r * 2 + thickness * 2) do
        # Unless specified, calculate a nice-looking "minimum" number of sides
        # sides = (r + Math::sqrt(r * 0.1) * 4).floor if sides.nil?
        sides = (2.0 * r * Math::PI).floor if sides.nil?

        # Calculate the inner and outer offsets from the "true" circle
        offs = thickness * 0.5
        r_in = r - offs
        r_out = r + offs

        # Calculate the angular increment
        ai = 360.0 / sides.to_f

        ang = 0
        while ang <= 359.9 do
          draw_quad(
            Gosu.offset_x(ang, r_in), Gosu.offset_y(ang, r_in), c,
            Gosu.offset_x(ang, r_out), Gosu.offset_y(ang, r_out), c,
            Gosu.offset_x(ang + ai, r_in), Gosu.offset_y(ang + ai, r_in), c,
            Gosu.offset_x(ang + ai, r_out), Gosu.offset_y(ang + ai, r_out), c,
            z, mode
          )
          ang += ai
        end
      end

      $rendered_circles[[r, c, thickness]].draw(x, y, z)
    end
  end

  class Window

    def draw_circle(x, y, r, c, z = 0, thickness = 1, sides = nil, mode = :default)
      Gosu::draw_circle(x, y, r, c, z, thickness, sides, mode)
    end

  end # Window class

end # Gosu module
