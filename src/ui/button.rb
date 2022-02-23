require_relative '../engine/entity'
require_relative 'tooltip'

module GosuGameJam2
  class Button < Entity
    include Tooltip

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

    def background_colour
      if point_inside?($cursor)
        Gosu::Color::FUCHSIA
      else
        Gosu::Color::GRAY
      end
    end

    def draw
      Gosu.draw_rect(position.x, position.y, width, height, background_colour)
      $regular_font.draw_text(text, position.x + 10, position.y + 10, 2)

      draw_tooltip
    end

    def tick
      if $click && point_inside?($cursor)
        on_click&.()
        $click = false
      end
    end
  end
end
