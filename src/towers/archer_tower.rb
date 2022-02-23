require_relative 'tower'

module GosuGameJam2
  class ArcherTower < Tower
    def initialize(owner:, **kw)
      super(
        owner: owner,
        target_team: :them,
        cooldown: 30,
        **kw
      )
    end

    def self.tower_name
      "Archer"
    end

    def self.radius
      200
    end
    
    def self.image
      Res.image('archer_tower.png')
    end

    def self.description
      <<~END
        Periodically deals damage
        to one target in a small
        range.
      END
    end

    def effect
      target = targets.sample
      target.damage(10)
      create_trail(to: target.position, colour: Gosu::Color::WHITE, intensity: 0.5)
    end
  end
end
