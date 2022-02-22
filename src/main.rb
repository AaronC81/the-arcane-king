require 'gosu'
require_relative 'res'
require_relative 'units/unit'
require_relative 'towers/tower'
require_relative 'towers/archer_tower'
require_relative 'towers/lancer_tower'
require_relative 'towers/catapult_tower'
require_relative 'towers/ballista_tower'
require_relative 'towers/cannon_tower'
require_relative 'towers/bonfire_tower'
require_relative 'ui/button'
require_relative 'world'
require_relative 'circle'

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

      $world.path = [
        [300, :east],
        [800, :south],
        [500, :east],
        [100, :north],
        [1000, :east],
        [500, :south],
        [700, :west],
        [700, :south],
        [1200, :east],
        [200, :north],
      ]
      $world.path_start = Point.new(20, HEIGHT / 2)

      [ArcherTower, LancerTower, CatapultTower, BallistaTower, CannonTower, BonfireTower].each.with_index do |klass, i|
        $world.entities << Button.new(
          position: Point.new(WIDTH - 150, 200 + i * 50),
          width: 120,
          height: 30,
          text: klass.tower_name,
          tooltip: klass.description,
          on_click: ->() { $world.placing_tower = klass }
        )
      end

      $world.entities << Button.new(
        position: Point.new(WIDTH - 150, HEIGHT - 100),
        width: 120,
        height: 30,
        text: "GO!",
        tooltip: "Spawn a wave of enemies!",
        on_click: ->() do
          5.times do |i|
            $world.units << Unit.new(
              position: $world.path_start.clone + Point.new(i * 40.0, 0.0),
              path: $world.path,
              speed: 2.0,
              max_health: 100,
              team: :enemy,
            )
          end
        end
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
      $world.entities.each do |e|
        e.tick
      end

      # TODO: bounds, gold, etc check
      if $click && $world.placing_tower && $world.placing_tower.can_place_at?($cursor)
        $world.towers << $world.placing_tower.new(owner: :friendly, position: $cursor)
        $world.placing_tower = nil
      end 

      $click = false
    end

    def draw
      # Draw route lines
      $world.trace_path do |s, e|
        Gosu.draw_line(
          s.x, s.y, Gosu::Color::GRAY,
          e.x, e.y, Gosu::Color::GRAY,
        )
      end
      
      $world.units.each do |u|
        u.draw
      end
      $world.towers.each do |t|
        t.draw
      end
      $world.entities.each do |e|
        e.draw unless e.is_a?(Button) && $world.placing_tower
      end

      $world.placing_tower&.draw_blueprint($cursor)

      $regular_font.draw_text("Castle Health:", 1450, 70, 100)
      $regular_font.draw_text("#{$world.castle_health}/#{$world.max_castle_health}", 1450, 100, 100)
      $regular_font.draw_text("#{Gosu.fps} FPS", 0, 0, 100)

      if $world.placing_tower
        Res.image("left_click.png").draw(1450, 203)
        $regular_font.draw_text("Confirm", 1490, 210, 100)

        Res.image("right_click.png").draw(1450, 303)
        $regular_font.draw_text("Cancel\nbuilding", 1490, 300, 100)
      end
    end

    def needs_cursor?
      true
    end  

    def button_down(id)
      super # Fullscreen with Alt+Enter/Cmd+F/F11

      case id
      when Gosu::MsLeft
        $click = true
      when Gosu::MsRight
        $world.placing_tower = nil
      end
    end
  end
end

GosuGameJam2::GameWindow.new.show
