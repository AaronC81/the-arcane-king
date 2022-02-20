require_relative '../engine/entity'

module GosuGameJam2
  class Button < Entity
    def initialize(width:, height:, text:, on_click: nil, tooltip: nil, **kw)
      super(**kw)
      @width = width
      @height = height
      @text = text
      @on_click = on_click
      @tooltip = tooltip
    end

    attr_accessor :width
    attr_accessor :height

    # The text to display on this button.
    attr_accessor :text

    # A proc to run when the button is clicked.
    attr_accessor :on_click

    # An optional tooltip to display when the button is hovered. The tooltip may have multiple
    # lines.
    attr_accessor :tooltip

    def background_colour
      if point_inside?($cursor)
        Gosu::Color::FUCHSIA
      else
        Gosu::Color::GRAY
      end
    end

    def point_inside?(point)
      point.x >= position.x && point.x <= position.x + width \
        && point.y >= position.y && point.y <= position.y + height
    end

    def draw
      Gosu.draw_rect(position.x, position.y, width, height, background_colour)
      $regular_font.draw_text(text, position.x + 10, position.y + 10, 2)

      if tooltip && point_inside?($cursor)
        # Find how tall the tooltip needs to be
        lines = tooltip.split("\n")
        text_width = lines.map { |l| $regular_font.text_width(l) }.max
        text_height = lines.length * $regular_font.height

        # Draw rectangle with some padding, clamp to edges of screen
        padding = 10
        origin_x = [$cursor.x, WIDTH - (text_width + padding * 2)].min
        origin_y = [$cursor.y, text_height + padding * 2].max
        Gosu.draw_rect(
          origin_x, origin_y - text_height - padding * 2,
          text_width + padding * 2, text_height + padding * 2,
          Gosu::Color.argb(0xAA, 0x00, 0x00, 0x00), 3,
        )
        $regular_font.draw_text(
          tooltip, origin_x + padding, origin_y - text_height - padding, 3, 1, 1,
          Gosu::Color::WHITE,
        )
      end
    end

    def tick
      if $click && point_inside?($cursor)
        on_click&.()
        $click = false
      end
    end
  end
end
