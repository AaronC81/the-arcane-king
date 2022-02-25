require_relative '../engine/entity'
require_relative 'tooltip'

module GosuGameJam2
  class Button < Entity
    include Tooltip

    def initialize(width:, height:, text:, on_click: nil, enabled: nil, tooltip: nil, **kw)
      super(**kw)
      @width = width
      @height = height
      @text = text
      @on_click = on_click
      @enabled = enabled || ->{ true }
      @tooltip = tooltip
    end

    attr_accessor :width
    attr_accessor :height

    # The text to display on this button.
    attr_accessor :text

    # A proc to run when the button is clicked.
    attr_accessor :on_click

    # A proc to run to check the button is enabled.
    attr_accessor :enabled

    def background_colour
      return THEME_BROWN unless enabled.()

      if point_inside?($cursor)
        Gosu::Color.rgb(70, 65, 50)
      else
        Gosu::Color.rgb(132, 116, 95)
      end
    end

    def draw
      # Draw fill
      Gosu.draw_rect(position.x, position.y, width, height, background_colour)

      # Draw border
      border_width = 2
      border_colour = THEME_BROWN
      Gosu.draw_outline_rect(position.x, position.y, width, height, THEME_BROWN, 2)

      # Draw text
      text_width = $regular_font.text_width(text)
      $regular_font.draw_text(text, position.x + (width - text_width) / 2, position.y + 3, 2)
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
