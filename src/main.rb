require 'gosu'
require_relative 'units/unit'
require_relative 'towers/tower'
require_relative 'towers/archer_tower'
require_relative 'ui/button'
require_relative 'world'
require_relative 'circle'

Gosu::enable_undocumented_retrofication

module GosuGameJam2
  WIDTH = 1600
  HEIGHT = 900

  class GameWindow < Gosu::Window
    def initialize
      super(WIDTH, HEIGHT)
      $world = World.new

      # TODO: Find better font and bundle into files
      $small_font = Gosu::Font.new(14, name: "Arial")
      $regular_font = Gosu::Font.new(20, name: "Arial")

      $world.units << Unit.new(
        position: Point.new(30, 30),
        path: [[1000, :east], [500, :south]],
        speed: 2,
        max_health: 100,
        team: :enemy,
      )

      $world.towers << ArcherTower.new(
        position: Point.new(950, 110),
        owner: :friendly,
      )

      @button = Button.new(
        position: Point.new(1500, 70),
        width: 120,
        height: 30,
        text: "Hello!",
        tooltip: "This is\nsome\ntext",
        on_click: ->() { puts "hey" }
      )
    end

    def update
      $cursor = Point.new(mouse_x.to_i, mouse_y.to_i)

      $world.units.each do |u|
        u.tick
      end
      $world.towers.each do |t|
        t.tick
      end
      @button.tick

      $click = false
    end

    def draw
      $world.units.each do |u|
        u.draw
      end
      $world.towers.each do |t|
        t.draw
      end
      @button.draw
    end

    def needs_cursor?
      true
    end  

    def button_down(id)
      super # Fullscreen with Alt+Enter/Cmd+F/F11

      case id
      when Gosu::MsLeft
        $click = true
      end
    end
  end
end

GosuGameJam2::GameWindow.new.show
