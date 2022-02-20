require 'gosu'
require_relative 'res'
require_relative 'units/unit'
require_relative 'towers/tower'
require_relative 'towers/archer_tower'
require_relative 'towers/trebuchet_tower'
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

      @path = [
        [400, :east],
        [800, :south],
        [800, :east],
        [100, :north],
      ]
      @start_point = Point.new(20, HEIGHT / 2)

      [ArcherTower, TrebuchetTower].each.with_index do |klass, i|
        $world.entities << Button.new(
          position: Point.new(WIDTH - 100, 70 + i * 50),
          width: 120,
          height: 30,
          text: klass.tower_name,
          tooltip: klass.description,
          on_click: ->() { $world.placing_tower = klass }
        )
      end

      $world.entities << Button.new(
        position: Point.new(WIDTH - 100, HEIGHT - 100),
        width: 120,
        height: 30,
        text: "GO!",
        tooltip: "Spawn a wave of enemies!",
        on_click: ->() do
          5.times do |i|
            $world.units << Unit.new(
              position: @start_point.clone + Point.new(i * 40, 0),
              path: @path,
              speed: 2,
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
      if $click && $world.placing_tower
        $world.towers << $world.placing_tower.new(owner: :friendly, position: $cursor)
        $world.placing_tower = nil
      end 

      $click = false
    end

    def draw
      # Draw route lines
      line_curr_point = @start_point.clone
      @path.each do |(pos, dir)|
        new_point = Point.new(
          (dir == :east || dir == :west) ? pos : line_curr_point.x,
          (dir == :north || dir == :south) ? pos : line_curr_point.y,
        )
        Gosu.draw_line(
          line_curr_point.x, line_curr_point.y, Gosu::Color::GRAY,
          new_point.x, new_point.y, Gosu::Color::GRAY,
        )
        line_curr_point = new_point
      end
      
      $world.units.each do |u|
        u.draw
      end
      $world.towers.each do |t|
        t.draw
      end
      $world.entities.each do |e|
        e.draw
      end

      $world.placing_tower&.draw_blueprint($cursor)

      $regular_font.draw_text("#{Gosu.fps} FPS", 0, 0, 100)
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
