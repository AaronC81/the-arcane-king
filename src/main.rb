require 'gosu'
require_relative 'res'
require_relative 'ui/button'
require_relative 'shapes'

require_relative 'units/unit'
require_relative 'units/scout_unit'
require_relative 'units/brute_unit'
require_relative 'units/knight_unit'
require_relative 'units/giant_unit'
require_relative 'units/cavalry_unit'
require_relative 'units/invader_unit'

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

  THEME_BROWN = Gosu::Color.rgb(50, 45, 39)

  class GameWindow < Gosu::Window
    def initialize
      super(WIDTH, HEIGHT)
      $world = World.new
            
      $regular_font_medieval = Gosu::Font.new(28, name: "#{__dir__}/../res/font/enchanted_land.otf")
      $regular_font_plain = Gosu::Font.new(20, name: "Arial")

      $regular_font = $regular_font_medieval

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

      make_button = ->(x, y, klass) do
        $world.entities << Button.new(
          position: Point.new(x, y),
          width: 120,
          height: 30,
          text: klass.tower_name,
          tooltip: "#{klass.description}\nCost: #{klass.gold_cost} gold",
          enabled: -> { $world.gold >= klass.gold_cost },
          on_click: -> { $world.placing_tower = klass },
        )
      end
      make_button.(WIDTH - 300, 230, ArcherTower)
      make_button.(WIDTH - 165, 230, OutpostTower)
      make_button.(WIDTH - 300, 280, WatchtowerTower)
      make_button.(WIDTH - 165, 280, CatapultTower)
      make_button.(WIDTH - 300, 330, BallistaTower)
      make_button.(WIDTH - 165, 330, CannonTower)

      $world.entities << Button.new(
        position: Point.new(WIDTH - 270, HEIGHT - 120),
        width: 200,
        height: 30,
        text: "GO!",
        tooltip: "Spawn a wave of enemies!",
        on_click: ->() do
          # Wave difficulty curve
          $world.generate_wave(($world.wave ** 1.75) * 25)
        end
      )
    end

    def update(fast_forward_tick_num: 0)
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

      if $click && $world.placing_tower && $world.placing_tower.can_place_at?($cursor)
        $world.towers << $world.placing_tower.new(owner: :friendly, position: $cursor)
        $world.gold -= $world.placing_tower.gold_cost
        $world.placing_tower = nil
      end 

      $click = false

      # If a wave just ended, increment wave number
      $world.wave += 1 if @wave_in_progress_last_tick && !$world.wave_in_progress?

      @wave_in_progress_last_tick = $world.wave_in_progress?

      # Fast-forward implementation - tick twice if space down
      if Gosu.button_down?(Gosu::KbSpace) && fast_forward_tick_num < 3
        update(fast_forward_tick_num: fast_forward_tick_num + 1)
      end
    end

    def draw
      # Draw ground
      (WIDTH / TILE_SIZE + 1).round.times do |x|
        (HEIGHT / TILE_SIZE).round.times do |y|
          Res.image("ground/flat.png").draw(x * TILE_SIZE, y * TILE_SIZE, 0)
        end
      end

      # Draw UI background
      Res.image('scroll.png').draw(WIDTH - 335, 25)
      
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
        e.draw unless e.is_a?(Button) && ($world.placing_tower || $world.wave_in_progress?)
      end

      $world.placing_tower&.draw_blueprint($cursor)

      # Draw health
      $regular_font.draw_text("Castle", 1300, 100, 100, 1, 1, THEME_BROWN)
      $regular_font.draw_text("#{$world.castle_health}/#{$world.max_castle_health}", 1485, 100, 100, 1, 1, THEME_BROWN)
      Gosu.draw_outline_rect(
        WIDTH - 300, 130,
        260, 20,
        THEME_BROWN, 2
      )
      Gosu.draw_rect(
        WIDTH - 300, 130,
        260 * ($world.castle_health.to_f / $world.max_castle_health), 20,
        THEME_BROWN
      )

      $regular_font.draw_text("Gold: #{$world.gold}", 1300, 190, 100, 1, 1, THEME_BROWN)
      $regular_font.draw_text("Wave: #{$world.wave}", 1500, 190, 100, 1, 1, THEME_BROWN)

      $regular_font.draw_text("#{Gosu.fps} FPS", 0, 0, 100)

      if $world.placing_tower
        Res.image("left_click.png").draw(1350, 303)
        $regular_font.draw_text("Confirm", 1390, 310, 100, 1, 1, THEME_BROWN)

        Res.image("right_click.png").draw(1350, 353)
        $regular_font.draw_text("Cancel building", 1390, 360, 100, 1, 1, THEME_BROWN)
      end

      if $world.wave_in_progress?
        $regular_font.draw_text(
          "#{$world.remaining_enemies} enemies remaining\n\nHold SPACE to fast-forward",
          1320, 300, 100, 1, 1, THEME_BROWN
        )
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
      when Gosu::KbF
        if $regular_font == $regular_font_medieval
          $regular_font = $regular_font_plain
        else
          $regular_font = $regular_font_medieval
        end
      end
    end
  end
end

GosuGameJam2::GameWindow.new.show
