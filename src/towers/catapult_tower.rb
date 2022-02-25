require_relative 'tower'

module GosuGameJam2
  class CatapultTower < Tower
    def initialize(owner:, **kw)
      super(
        owner: owner,
        target_team: :them,
        cooldown: 200,
        **kw
      )
    end
    
    def self.tower_name
      "Catapult"
    end
    
    def self.radius
      400
    end

    def self.image
      Res.image('catapult.png')
    end

    def self.gold_cost
      120
    end

    def self.description
      <<~END
        Slowly fires powerful
        projectiles across a long
        range to deal huge damage.
      END
    end

    def effect
      target = targets.sample
      target.damage(100)
      create_trail(to: target.position, colour: Gosu::Color::WHITE, intensity: 1)
      rotate_towards(target.position)

      Res.sample("audio/catapult.wav").play(0.5)
    end
  end
end
