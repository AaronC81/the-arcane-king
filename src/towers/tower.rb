require_relative '../engine/entity'
require_relative '../engine/animation'
require_relative '../effects/projectile_trail'

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

    def self.image
      # Subclasses should override this, but we'll provide a default for in-development towers
      nil
    end

    def image
      self.class.image
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

    def create_trail(intensity:, **kw)
      $world.entities << ProjectileTrail.new(
        from: self.position,
        **kw,
        opacity: (intensity * 255).round,
      )
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
      if self.class.image
        super
        sprite_width = image.width
        sprite_height = image.height
      else
        # Draw tower (temporary)
        sprite_width = 5
        sprite_height = 5
        Gosu.draw_rect(
          position.x - sprite_width, position.y - sprite_height, sprite_width * 2, sprite_height * 2,
          Gosu::Color::WHITE,
        )
      end

      # Draw a circle for the radius
      Gosu.draw_circle(position.x, position.y, radius, Gosu::Color::WHITE)
    end

    # Draw a "blueprint" of this tower while the player is deciding where to place it. 
    def self.draw_blueprint(pos)
      if image
        w = image.width
        h = image.height
      else
        w = 10
        h = 10
      end

      if can_place_at?(pos)
        colour = Gosu::Color.argb(0xFF, 0x00, 0xFF, 0x00)
      else
        colour = Gosu::Color.argb(0xFF, 0xFF, 0x00, 0x00)
      end

      Gosu.draw_rect(pos.x - w / 2, pos.y - h / 2, w, h, colour)
      Gosu.draw_circle(pos.x, pos.y, radius, colour)
    end

    def self.can_place_at?(pos)
      if image
        w = image.width
        h = image.height
      else
        w = 10
        h = 10
      end

      this_bounding_box = Box.new(Point.new(pos.x, pos.y), w, h)

      # Check it's not overlapping any other towers
      $world.towers.each do |tower|
        next unless tower.image
        return false if tower.bounding_box.overlaps?(this_bounding_box)
      end

      # Check it's not on the path
      path_clearance = 20
      $world.trace_path do |s, e|
        min_x = [s.x, e.x].min
        max_x = [s.x, e.x].max
        min_y = [s.y, e.y].min
        max_y = [s.y, e.y].max

        # Draw a bounding box around each path segment
        # (+ w and + h offset for the funky bounding box of the tower)
        segment_box = Box.new(
          Point.new(min_x - path_clearance + w / 2, min_y - path_clearance + h / 2),
          (max_x - min_x) + path_clearance * 2,
          (max_y - min_y) + path_clearance * 2,
        )

        return false if this_bounding_box.overlaps?(segment_box)
      end

      # All good!
      true
    end
  end
end
