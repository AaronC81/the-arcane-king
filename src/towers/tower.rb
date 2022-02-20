require_relative '../engine/entity'

module GosuGameJam2
  # A tower in a fixed position, which has some effect.
  class Tower < Entity
    def initialize(owner:, target_team:, cooldown:, **kw)
      super(**kw)
      @radius = self.class.radius
      @owner = owner
      @target_team = target_team
      @cooldown = cooldown
      @remaining_cooldown = 0
    end

    # The radius which this tower can target.
    attr_accessor :radius

    # The team which owns this tower, :friendly or :enemy.
    attr_accessor :owner

    # The team which this tower's effects target, relative to the owner: :us or :them.
    attr_accessor :target_team

    # The time between this tower's effect can activate, in ticks.
    attr_accessor :cooldown

    # The time remaining until this tower's effect can next activate, in ticks.
    attr_accessor :remaining_cooldown

    def self.tower_name
      raise '.name unimplemented'
    end

    def self.radius
      raise '.radius unimplemented'
    end

    def self.description
      raise '.description unimplemented'
    end

    # Gets all units which this tower could target.
    def targets
      $world.find_units(team: absolute_target_team, radius: [position, radius])
    end

    # Gets the team name (:friendly or :enemy) which this will target, based on the owner and
    # relative target team.
    def absolute_target_team
      {
        [:friendly, :us] => :friendly,
        [:friendly, :them] => :enemy,
        [:enemy, :us] => :enemy,
        [:enemy, :them] => :friendly,
      }[[owner, target_team]]
    end

    def effect
      # For subclasses to override!
    end

    def tick
      super

      if self.remaining_cooldown > 0
        self.remaining_cooldown -= 1
      else
        # No point firing if there's no target!
        if targets.any?
          effect 
          self.remaining_cooldown = cooldown
        end
      end
    end

    def draw
      # Draw tower (temporary)
      sprite_width = 5
      sprite_height = 5
      Gosu.draw_rect(
        position.x - sprite_width, position.y - sprite_height, sprite_width * 2, sprite_height * 2,
        Gosu::Color::WHITE,
      )

      # Draw a circle for the radius
      Gosu.draw_circle(position.x, position.y, radius, Gosu::Color::WHITE)

      $small_font.draw_text("#{self.class.tower_name}\n#{remaining_cooldown}/#{cooldown}", position.x + 7, position.y - sprite_height, 1)
    end

    # Draw a "blueprint" of this tower while the player is deciding where to place it. 
    def self.draw_blueprint(pos)
      transparent_red = Gosu::Color.argb(0xFF, 0xFF, 0x00, 0x00)
      Gosu.draw_rect(pos.x - 5, pos.y - 5, 10, 10, transparent_red)
      Gosu.draw_circle(pos.x, pos.y, radius, transparent_red)
    end
  end
end
