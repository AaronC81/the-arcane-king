require 'gosu'
require_relative 'units/unit'

Gosu::enable_undocumented_retrofication

module GosuGameJam2
  class GameWindow < Gosu::Window
    def initialize
      super(1600, 900)
      @unit = Unit.new(
        position: Point.new(30, 30),
        path: [[1000, :east], [500, :south]],
        speed: 3,
        max_health: 100,
        team: :friendly,
      )
    end

    def update
      if Gosu.button_down?(Gosu::KB_F)
        self.fullscreen = !fullscreen?
        sleep 1 # really rubbish debounce
      end
      @unit.tick
    end

    def draw
      @unit.draw
    end
  end
end

GosuGameJam2::GameWindow.new.show
