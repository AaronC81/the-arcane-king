require 'gosu'
require_relative 'res'
require_relative 'ui/button'
require_relative 'shapes'
require_relative 'menu'
require_relative 'engine/transition'

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

$seen_menu = false
$cursor = TheArcaneKing::Point.new(0, 0)

$all_boxes = []

module TheArcaneKing
  WIDTH = 1600
  HEIGHT = 900
  TILE_SIZE = 60

  THEME_BROWN = Gosu::Color.rgb(50, 45, 39)

  class GameWindow < Gosu::Window
    def initialize
      super(WIDTH, HEIGHT)
      $world = World.new

      @showing_menu = true unless $seen_menu # Don't show menu on reset
      @showing_tutorial = false
      @transition = Transition.new
            
      $regular_font_medieval = Gosu::Font.new(28, name: "#{__dir__}/../res/font/enchanted_land.otf")
      $regular_font_plain = Gosu::Font.new(20, name: "Arial")

      $large_font_medieval = Gosu::Font.new(50, name: "#{__dir__}/../res/font/enchanted_land.otf")
      $large_font_plain = Gosu::Font.new(30, name: "Arial")

      $regular_font = $regular_font_medieval
      $large_font = $large_font_medieval

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
        text: "Bring on the next wave!",
        tooltip: <<~END,
          Spawn the next wave of enemies!

          You will not be able to build
          more towers or buy more spell
          charges until the end of the
          wave.
        END
        on_click: ->() do
          # Wave difficulty curve
          cost = ($world.wave ** 1.75) * 25
          if $world.wave >= 20
            # Difficulty curve begins to become too easy if they've survived this long - ramp it up
            # hard!
            cost *= ($world.wave - 19) * 1.5
          end
          $world.generate_wave(cost)

          # Play a battle song
          Res.song('audio/battle_music.wav').play(true)
        end
      )

      @retry_button = Button.new(
        position: Point.new(WIDTH - 270, 550),
        width: 200,
        height: 30,
        text: "Try again",
        on_click: -> { initialize },
      )

      # Set up magic buttons
      magic_button_keys = ->(name) do
        {
          enabled: ->do 
            if $world.wave_in_progress?
              $world.magic_charges[name] > 0
            else
              $world.gold >= 25 && $world.magic_charges[name] < 5
            end
          end,
          on_click: ->do
            if $world.wave_in_progress?
              $world.casting_spell = name
            else
              $world.gold -= 25 ; $world.magic_charges[name] += 1
            end
          end,
        }
      end
      @magic_buttons = [
        Button.new(
          position: Point.new(WIDTH - 290, 420),
          image: Res.image('magic/smite.png'),
          **magic_button_keys.(:smite),
          tooltip: <<~END
            SMITE enemies in an area,
            dealing damage to them.

            Cost: 25 gold
          END
        ),
        Button.new(
          position: Point.new(WIDTH - 155, 420),
          image: Res.image('magic/stun.png'),
          **magic_button_keys.(:stun),
          tooltip: <<~END
            STUN enemies in an area,
            briefly immobilising them.

            Cost: 25 gold
          END
        ),
        Button.new(
          position: Point.new(WIDTH - 290, 580),
          image: Res.image('magic/slow.png'),
          **magic_button_keys.(:slow),
          tooltip: <<~END
            Cast a lasting rift which
            SLOWS enemies passing
            through it.

            Cost: 25 gold
          END
        ),
        Button.new(
          position: Point.new(WIDTH - 155, 580),
          image: Res.image('magic/bolt.png'),
          **magic_button_keys.(:bolt),
          tooltip: <<~END
            Fire a BOLT which kills
            one to three random enemies
            in the target area.

            Cost: 25 gold
          END
        ),
      ]

      Res.song('audio/build_music.wav').play(true)

      @wave_in_progress_last_tick = false
    end

    def update(fast_forward_tick_num: 0)
      @transition.tick

      return if @showing_menu || @showing_tutorial

      $cursor = Point.new(mouse_x.to_i, mouse_y.to_i)

      $world.tick
      $world.units.each do |u|
        u.tick
      end
      $world.towers.each do |t|
        t.tick
      end
      $world.entities.each do |e|
        e.tick unless e.is_a?(Button) && ($world.placing_tower || $world.wave_in_progress? || $world.defeated?)
      end
      @retry_button.tick if $world.defeated?
      @magic_buttons.each(&:tick) unless $world.defeated?

      if $click && $world.placing_tower && $world.placing_tower.can_place_at?($cursor)
        Res.sample('audio/place.wav').play

        $world.towers << $world.placing_tower.new(owner: :friendly, position: $cursor)
        $world.gold -= $world.placing_tower.gold_cost
        $world.placing_tower = nil
      end 

      if $click && $world.casting_spell
        $world.cast
        $world.casting_spell = nil
      end

      $click = false

      # If a wave just ended, increment wave number and stop music
      if @wave_in_progress_last_tick && !$world.wave_in_progress? && !$world.defeated?
        $world.wave += 1 
        Gosu::Song.current_song.stop
        Res.song('audio/build_music.wav').play(true)

        # Also, if we were about to cast a spell, stop
        $world.casting_spell = nil

        # Give 15 gold, just so the player has some kind of income even if they're getting
        # completely obliterated
        $world.gold += 15
      end

      @wave_in_progress_last_tick = $world.wave_in_progress?

      # Fast-forward implementation - tick twice if space down
      if Gosu.button_down?(Gosu::KbSpace) && fast_forward_tick_num < 3
        update(fast_forward_tick_num: fast_forward_tick_num + 1)
      end
    end

    def draw
      @transition.draw

      if @showing_menu
        Menu.draw_main_menu
        return
      end

      if @showing_tutorial
        Menu.draw_tutorial_overlay
      end

      # Draw ground
      Res.image("ground/grass.png").draw(0, 0, 0)

      # Draw castle
      Res.image("castle.png").draw(1038, -95, 0)

      # Draw UI background
      Res.image('scroll.png').draw(WIDTH - 335, 25, 0)

      unless $world.placing_tower || $world.casting_spell || $world.defeated?
        # Draw magic buttons
        @magic_buttons.each(&:draw)

        # Draw magic charges
        [:smite, :stun, :slow, :bolt].zip(@magic_buttons).each do |magic, btn|
          charges = $world.magic_charges[magic]

          pt = btn.position + Point.new(43 - 8 * (charges - 1), 105)
          charges.times do |i|
            Res.image('magic/dot.png').draw(pt.x + i * 15, pt.y, 100)
          end
        end
      end

      # Draw path
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
        e.draw unless e.is_a?(Button) && ($world.placing_tower || $world.wave_in_progress? || $world.defeated?)
      end

      if $world.defeated?
        $world.placing_tower = nil
        @retry_button.draw
        $large_font.draw_text("Your castle\nhas fallen!", 1370, 300, 100, 1, 1, THEME_BROWN)
        $regular_font.draw_text("Your kingdom's army was defeated\non wave #{$world.wave} of enemy invasion.", 1320, 410, 100, 1, 1, THEME_BROWN)
        return
      end

      # Draw things which are currently in progress
      $world.placing_tower&.draw_blueprint($cursor)
      $world.draw_cast_radius

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
        260 * [($world.castle_health.to_f / $world.max_castle_health), 0].max, 20,
        THEME_BROWN
      )

      $regular_font.draw_text("Gold: #{$world.gold}", 1300, 190, 100, 1, 1, THEME_BROWN)
      $regular_font.draw_text("Wave: #{$world.wave}", 1500, 190, 100, 1, 1, THEME_BROWN)

      if $world.placing_tower
        Res.image("left_click.png").draw(1350, 303, 0)
        $regular_font.draw_text("Confirm", 1390, 310, 100, 1, 1, THEME_BROWN)

        Res.image("right_click.png").draw(1350, 353, 0)
        $regular_font.draw_text("Cancel building", 1390, 360, 100, 1, 1, THEME_BROWN)
      end

      if $world.casting_spell
        Res.image("left_click.png").draw(1350, 453, 0)
        $regular_font.draw_text("Cast", 1390, 460, 100, 1, 1, THEME_BROWN)

        Res.image("right_click.png").draw(1350, 503, 0)
        $regular_font.draw_text("Cancel casting", 1390, 510, 100, 1, 1, THEME_BROWN)
      end

      if $world.wave_in_progress?
        $regular_font.draw_text(
          "#{$world.remaining_enemies} enemies remaining\n\nHold SPACE to fast-forward",
          1320, 300, 100, 1, 1, THEME_BROWN
        )
      end

      # Draw all boxes
      if ENV['DEBUG_BOXES']
        $all_boxes.each do |box|
          Gosu.draw_outline_rect(box.origin.x, box.origin.y, box.width, box.height, Gosu::Color::FUCHSIA, 1)
        end

        $all_boxes = []
      end
    end

    def needs_cursor?
      true
    end  

    def button_down(id)
      super # Fullscreen with Alt+Enter/Cmd+F/F11

      case id
      when Gosu::MsLeft
        if @showing_menu && !@transition.ongoing?
          $seen_menu = true

          @transition.fade_out(60) do
            @showing_menu = false
            @showing_tutorial = true
            @transition.fade_in(60) {}
          end
        end

        if @showing_tutorial
          @showing_tutorial = false
          $click = false # Do not click through
          return
        end

        $click = true
      when Gosu::MsRight
        $world.placing_tower = nil
        $world.casting_spell = nil
      when Gosu::KbF
        if $regular_font == $regular_font_medieval
          $regular_font = $regular_font_plain
          $large_font = $large_font_plain
        else
          $regular_font = $regular_font_medieval
          $large_font = $large_font_medieval
        end
      end
    end
  end
end

TheArcaneKing::GameWindow.new.show
