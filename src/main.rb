require 'gosu'
require_relative 'units/unit'
require_relative 'towers/tower'
require_relative 'towers/archer_tower'
require_relative 'world'
require_relative 'circle'

Gosu::enable_undocumented_retrofication

module GosuGameJam2
  class GameWindow < Gosu::Window
    def initialize
      super(1600, 900)
      $world = World.new

      # TODO: Find better font and bundle into files
      $font = Gosu::Font.new(14, name: "Arial")

      $world.units << Unit.new(
        position: Point.new(30, 30),
        path: [[1000, :east], [500, :south]],
        speed: 2,
        max_health: 100,
        team: :friendly,
      )

      $world.towers << ArcherTower.new(
        position: Point.new(950, 110),
        owner: :enemy,
      )
    end

    def update
      if Gosu.button_down?(Gosu::KB_F)
        self.fullscreen = !fullscreen?
        sleep 1 # really rubbish debounce
      end
      $world.units.each do |u|
        u.tick
      end
      $world.towers.each do |t|
        t.tick
      end
    end

    def draw
      $world.units.each do |u|
        u.draw
      end
      $world.towers.each do |t|
        t.draw
      end
    end
  end
end

GosuGameJam2::GameWindow.new.show
