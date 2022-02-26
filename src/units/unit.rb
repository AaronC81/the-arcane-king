require_relative '../engine/entity'

module TheArcaneKing
  # A unit which moves along a fixed path automatically.
  class Unit < Entity
    def initialize(max_health:, team:, speed:, reward:, **kw)
      super(**kw)
      @max_health = max_health
      @health = max_health
      @team = team
      @path = $world.path.clone.map { |p, d| [p + rand(-0.3..0.3), d] }
      @position = $world.path_start.clone + Point.new(-10, rand(-10..10))
      @speed = speed
      @speed_buffs = {}
      @path_index = 0
      @reward = reward

      @health_bar_flash_ticks = 0

      # We'll spawn facing east
      self.rotation = 90
    end

    # The team which this unit belongs to, either :friendly or :enemy.
    attr_accessor :team

    # The max health of this unit.
    attr_accessor :max_health

    # The current health of this unit.
    attr_accessor :health

    # Speed changes which are being applied to this unit. A hash of the tower applying the debuff
    # to [multiplier, duration]
    attr_accessor :speed_buffs

    # The gold reward for defeating this unit.
    attr_accessor :reward

    # Deals damage to this unit, killing it if its health falls to or below zero.
    def damage(amount)
      self.health -= amount
      @health_bar_flash_ticks = 5

      if health <= 0
        $world.units.delete(self)

        # Reward gold equal to max health
        # Rewards diminish over waves to stop player getting an obscene amount of money, but never
        # less than 10% of original
        $world.gold += [reward - (($world.wave) * 4).round, (reward * 0.05).round].max
      end
    end

    # The path being followed by this unit, of the form [Integer, Symbol], where the Symbol is a
    # cardinal direction (:north etc). The unit will travel in the direction until it reaches the
    # given coordinate, where it will move to the next path component.
    attr_accessor :path

    # The index into the #path which is currently being moved along.
    attr_accessor :path_index

    # The cardinal direction in which this unit is currently moving.
    def direction
      path[path_index][1]
    end

    # Returns true if the unit should advance to the next step in its path.
    def path_step_complete?
      coord = $world.path_component_to_coordinate(path[path_index])

      # Ugly special case - if this is the last element of the path, terminate when we hit the
      # castle
      coord = $world.path.last[0] * TILE_SIZE if path[path_index + 1].nil?

      (direction == :north && position.y <= coord) \
        || (direction == :south && position.y >= coord) \
        || (direction == :east && position.x >= coord) \
        || (direction == :west && position.x <= coord) \
    end

    def on_path?
      !path.nil? && !path[path_index].nil?
    end

    # The base speed at which this unit moves, in units-per-tick.
    attr_accessor :speed

    # The current speed at which this unit moves, taking into account any changes, in units-per-tick.
    def current_speed
      s = speed
      speed_buffs.each do |_, (change, _)|
        s *= change
      end
      s
    end

    def tick
      super

      # Tick down speed buffs, and delete any which have expired
      speed_buffs.each do |k, v|
        v[1] -= 1
      end
      speed_buffs.delete_if do |k, v|
        v[1] <= 0
      end

      # If this object is still following a path...
      if on_path?
        # Move based on speed
        self.position += Point.new(*{
          north: [0, -current_speed],
          south: [0, current_speed],
          east: [current_speed, 0],
          west: [-current_speed, 0],
        }[direction])

        # If we're past the path boundary, switch directions
        if path_step_complete?
          self.path_index += 1 
          self.rotation = {
            north: 0,
            east: 90,
            south: 180,
            west: 270,
          }[direction] if on_path?
        end
      else
        # This unit reached the end!
        # Destroy it and, if it's an enemy, take its health off the castle health
        $world.units.delete(self)
        if team == :enemy
          $world.castle_health -= health
        end
      end
    end

    def draw
      if animations.any?
        super
      else
        # Draw unit (temporary)
        sprite_width = 15
        sprite_height = 15
        Gosu.draw_rect(
          position.x - sprite_width, position.y - sprite_height, sprite_width * 2, sprite_height * 2,
          { friendly: Gosu::Color::BLUE, enemy: Gosu::Color::RED }[team],
        )
      end

      # Draw a health bar
      health_bar_total_width = 25
      health_bar_remaining_width = ((health.to_f / max_health.to_f) * health_bar_total_width).round
      if @health_bar_flash_ticks > 0
        health_bar_colour = Gosu::Color::RED
        @health_bar_flash_ticks -= 1
      else
        health_bar_colour = Gosu::Color::GREEN
      end
      Gosu.draw_rect(
        position.x - health_bar_total_width / 2,
        position.y - 25,
        health_bar_remaining_width,
        5,
        health_bar_colour,
        100,
      )
      Gosu.draw_rect(
        position.x - health_bar_total_width / 2 + health_bar_remaining_width,
        position.y - 25,
        health_bar_total_width - health_bar_remaining_width,
        5,
        Gosu::Color::GRAY,
        100,
      )
    end
  end
end
