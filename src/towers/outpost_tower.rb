require_relative 'tower'

module GosuGameJam2
  class OutpostTower < Tower
    def initialize(owner:, **kw)
      super(
        owner: owner,
        target_team: :them,
        cooldown: 5,
        **kw
      )
    end

    def self.tower_name
      "Outpost"
    end

    def self.radius
      75
    end

    def self.description
      <<~END
        An output stationed with melee
        lancers, with a very limited
        range. Rapidly stabs enemies,
        slowing those hit.
      END
    end

    def self.image
      Res.image('outpost.png')
    end

    def effect
      target = targets.sample
      target.damage(5)
      target.speed_buffs[self] = [0.7, 20]
      create_trail(to: target.position, colour: Gosu::Color::GRAY, intensity: 0.3)
    end
  end
end
