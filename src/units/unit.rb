require_relative '../engine/entity'

module GosuGameJam2
  # A unit which moves along a fixed path automatically.
  class Unit < Entity
    def initialize(max_health:, team:, path:, speed:, **kw)
      super(**kw)
      @max_health = max_health
      @health = max_health
      @team = team
      @path = path
      @speed = speed
      @path_index = 0

      @health_bar_flash_ticks = 0
    end

    # The team which this unit belongs to, either :friendly or :enemy.
    attr_accessor :team

    # The max health of this unit.
    attr_accessor :max_health

    # The current health of this unit.
    attr_accessor :health

    # Deals damage to this unit, killing it if its health falls to or below zero.
    def damage(amount)
      self.health -= amount
      @health_bar_flash_ticks = 5

      if health <= 0
        $world.units.delete(self)
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
      coord = path[path_index][0]
      (direction == :north && position.y <= coord) \
        || (direction == :south && position.y >= coord) \
        || (direction == :east && position.x >= coord) \
        || (direction == :west && position.x <= coord) \
    end

    def on_path?
      !path.nil? && !path[path_index].nil?
    end

    # The speed at which this unit moves, in units-per-tick.
    attr_accessor :speed

    def tick
      super

      # If this object is still following a path...
      if on_path?
        # Move based on speed
        self.position += Point.new(*{
          north: [0, -speed],
          south: [0, speed],
          east: [speed, 0],
          west: [-speed, 0],
        }[direction])

        # If we're past the path boundary, switch directions
        self.path_index += 1 if path_step_complete?
      end
    end

    def draw
      # Draw unit (temporary)
      sprite_width = 5
      sprite_height = 5
      Gosu.draw_rect(
        position.x - sprite_width, position.y - sprite_height, sprite_width * 2, sprite_height * 2,
        { friendly: Gosu::Color::BLUE, enemy: Gosu::Color::RED }[team],
      )

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
      )
      Gosu.draw_rect(
        position.x - health_bar_total_width / 2 + health_bar_remaining_width,
        position.y - 25,
        health_bar_total_width - health_bar_remaining_width,
        5,
        Gosu::Color::GRAY,
      )
    end
  end
end
