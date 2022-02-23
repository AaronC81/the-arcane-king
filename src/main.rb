require 'gosu'
require_relative 'res'
require_relative 'ui/button'
require_relative 'circle'

require_relative 'units/unit'
require_relative 'units/scout_unit'
require_relative 'units/brute_unit'

require_relative 'towers/tower'
require_relative 'towers/archer_tower'
require_relative 'towers/outpost_tower'
require_relative 'towers/catapult_tower'
require_relative 'towers/ballista_tower'
require_relative 'towers/cannon_tower'
require_relative 'towers/watchtower_tower'

require_relative 'world'


# Not a pixel art game, but fixes weird lines between tiles when upscaled
Gosu::enable_undocumented_retrofication

module GosuGameJam2
  WIDTH = 1600
  HEIGHT = 900
  TILE_SIZE = 60

  class GameWindow < Gosu::Window
    def initialize
      super(WIDTH, HEIGHT)
      $world = World.new
      
      # TODO: Find better font and bundle into files
      $small_font = Gosu::Font.new(14, name: "Arial")
      $regular_font = Gosu::Font.new(20, name: "Arial")

      $world.path = [
        [4,  :east],
        [-6, :south],
        [8,  :east],
        [4,  :north],
        [14, :east],
        [-2, :south],
        [12, :west],
        [-5, :south],
        [19, :east],
        [4, :north],
      ]
      $world.path_start = Point.new(0, HEIGHT / 2)

      [ArcherTower, OutpostTower, CatapultTower, BallistaTower, CannonTower, WatchtowerTower].each.with_index do |klass, i|
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
          $world.generate_wave(50)
        end
      )
    end

    def update
      $cursor = Point.new(mouse_x.to_i, mouse_y.to_i)

      $world.tick
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
      # Draw ground
      ((0.8 * WIDTH) / TILE_SIZE).round.times do |x|
        (HEIGHT / TILE_SIZE).round.times do |y|
          Res.image("ground/flat.png").draw(x * TILE_SIZE, y * TILE_SIZE, 0)
        end
      end
      
      # Draw route lines
      $world.trace_path do |s, e|
        Gosu.draw_line(
          s.x, s.y, Gosu::Color::GRAY,
          e.x, e.y, Gosu::Color::GRAY,
        )
      end

      # Draw path
      # TODO: castle at the end
      last_direction = :east
      $world.trace_path(with_direction: true) do |s, e, dir|
        min_x = [s.x, e.x].min
        max_x = [s.x, e.x].max
        min_y = [s.y, e.y].min
        max_y = [s.y, e.y].max

        # Work out the properties of the curve needed from the last path to this one
        name, rotation, flip_x, flip_y = *({
          #                    Name        Rot  FlipX  FlipY
          [:east,  :east ] => ["straight", 0,   false, false],
          [:west,  :west ] => ["straight", 0,   false, false],
          [:east,  :west ] => ["straight", 0,   false, false],
          [:west,  :east ] => ["straight", 0,   false, false],

          [:north, :north] => ["straight", 90,  false, false],
          [:south, :south] => ["straight", 90,  false, false],
          [:north, :south] => ["straight", 90,  false, false],
          [:south, :north] => ["straight", 90,  false, false],

          [:south, :east ] => ["corner",   0,   false, false],
          [:east,  :south] => ["corner",   0,   true,  true ],

          [:south, :west ] => ["corner",   0,   true,  false],
          [:west,  :south] => ["corner",   0,   false, true ],

          [:north, :east ] => ["corner",   0,   false, true ],
          [:east,  :north] => ["corner",   0,   true,  false],

          [:north, :west ] => ["corner",   0,   true,  true ],
          [:west,  :north] => ["corner",   0,   false, false],
        }[[last_direction, dir]])

        # Draw corner
        Res.image("ground/path_#{name}.png").draw_rot(
          s.x, s.y, 0, rotation, 0.5, 0.5,
          flip_x ? -1 : 1,
          flip_y ? -1 : 1,
        )
          
        # Draw rest of path
        if min_x != max_x
          ((max_x - min_x) / TILE_SIZE).times do |i|
            next if i == 0
            Res.image("ground/path_straight.png").draw_rot(min_x + i * TILE_SIZE, min_y, 0, 0)
          end
        else
          ((max_y - min_y) / TILE_SIZE).times do |i|
            next if i == 0
            Res.image("ground/path_straight.png").draw_rot(min_x, min_y + i * TILE_SIZE, 0, 90)
          end
        end

        last_direction = dir
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
