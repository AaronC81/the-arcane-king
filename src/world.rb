require_relative 'slow_field'

module TheArcaneKing
  class World
    SPAWNABLE_UNITS = [
      ScoutUnit, BruteUnit, CavalryUnit, GiantUnit, InvaderUnit, KnightUnit
    ]

    SPELL_RADII = {
      smite: [210, Gosu::Color.rgb(252, 169, 3)],
      stun: [210, Gosu::Color.rgb(246, 255, 0)],
      slow: [120, Gosu::Color.rgb(255, 0, 157)],
      bolt: [80, Gosu::Color.rgb(0, 17, 255)],
    }

    def initialize
      @units = []
      @towers = []
      @entities = []
      @pending_unit_spawns = []
      @magic_charges = {
        smite: 0,
        stun: 0,
        slow: 0,
        bolt: 0,
      }
      
      @max_castle_health = 2000
      @castle_health = @max_castle_health

      @wave = 1
      @wave = ENV['START_WAVE'].to_i if ENV['START_WAVE']

      @gold = 50
      @gold = 10000000 if ENV['INFINITE_GOLD']
    end

    # All units in the world.
    attr_accessor :units

    # All towers in the world.
    attr_accessor :towers

    # Other entities which need to be ticked and drawn.
    attr_accessor :entities

    # The tower class which is currently being placed.
    attr_accessor :placing_tower

    # The path which units will follow.
    attr_accessor :path

    # The position where the path starts.
    attr_accessor :path_start

    # The maximum health of the friendly castle.
    attr_accessor :max_castle_health

    # The remaining health of the friendly castle.
    attr_accessor :castle_health

    # Units which will be spawned in a certain amount of ticks.
    attr_accessor :pending_unit_spawns

    # The current wave number.
    attr_accessor :wave

    # The player's current gold balance.
    attr_accessor :gold
    
    # The player's charge of each magic spell.
    attr_accessor :magic_charges

    # The spell which is currently being cast.
    attr_accessor :casting_spell

    def wave_in_progress?
      remaining_enemies > 0
    end

    def remaining_enemies
      pending_unit_spawns.length + units.length
    end

    def defeated?
      castle_health <= 0
    end

    def tick
      pending_unit_spawns.map! do |(time, unit)|
        time -= 1
        if time <= 0
          $world.units << unit
          nil
        else
          [time, unit]
        end
      end
      pending_unit_spawns.compact!
    end

    # Finds and returns all units matching the given criteria:
    #   - `team:`, required, which team the units belong to.
    #   - `radius:`, given as [point, radius], filters only to units which are less than `radius`
    #     away from `point`.
    def find_units(team:, radius: nil)
      units
        .select { |u| u.team == team }
        .select do |u|
          if radius
            u.position.distance(radius[0]) <= radius[1]
          else
            true
          end
        end
    end

    # Yields the given block with each of the lines which make up the path, in the form [start, end]
    # where both are points.
    def trace_path(with_direction: false)
      line_curr_point = path_start.clone
      path.each do |(pos, dir)|
        pos = path_component_to_coordinate([pos, dir])
        new_point = Point.new(
          (dir == :east || dir == :west) ? pos : line_curr_point.x,
          (dir == :north || dir == :south) ? pos : line_curr_point.y,
        )

        points = [line_curr_point, new_point].map(&:clone)
        if with_direction
          yield [*points, dir]
        else
          yield points
        end

        line_curr_point = new_point
      end
    end

    # Converts one component of a path to a coordinate, on the axis which the path component moves
    # along.
    def path_component_to_coordinate(comp)
      pos, dir = *comp
      case dir
      when :east, :west
        pos * TILE_SIZE
      when :north, :south
        HEIGHT / 2 - pos * TILE_SIZE
      end
    end

    # Given a total cost, generates a new wave of enemy units.
    def generate_wave(cost)
      units_to_spawn = []

      loop do
        available_units = SPAWNABLE_UNITS.select { |u| u.spawn_cost <= cost }
        break if available_units.empty?

        unit = available_units.sample
        units_to_spawn << unit.new(:enemy)
        cost -= unit.spawn_cost
      end
   
      time = 10
      self.pending_unit_spawns = units_to_spawn.shuffle.map do |u|
        time += rand([5 / [wave / 3, 1].max, 0].max..[30 / [wave / 3, 1].max, 5].max)
        [time, u]
      end
    end

    # Draw the cast radius for the spell currently being cast.
    def draw_cast_radius
      return unless casting_spell

      radius, colour = SPELL_RADII[casting_spell]
      Gosu.draw_circle($cursor.x, $cursor.y, radius, colour, 100, 3)
    end

    # Cast the current spell.
    def cast
      radius, colour = SPELL_RADII[casting_spell]

      magic_charges[casting_spell] -= 1

      case casting_spell
      when :smite
        targets = find_units(team: :enemy, radius: [$cursor, radius])
        targets.each do |t|
          t.damage(rand(25..50))
        end
        Res.sample('audio/smite.wav').play
      
      when :stun
        targets = find_units(team: :enemy, radius: [$cursor, radius])
        targets.each do |t|
          t.speed_buffs[self] = [0, 240]
        end
        Res.sample('audio/stun.wav').play(0.6)

      when :slow
        $world.entities << SlowField.new(position: $cursor.clone)
        Res.sample('audio/slow.wav').play(0.3)

      when :bolt
        targets = find_units(team: :enemy, radius: [$cursor, radius])
        rand(1..3).times do
          targets.sample&.damage(99999)
        end
        Res.sample('audio/bolt.wav').play(0.3)

      else
        raise 'unknown spell - huh!?'
      end

      self.casting_spell = nil
    end
  end
end
