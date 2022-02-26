require_relative 'tower'

module TheArcaneKing
  class BallistaTower < Tower
    def initialize(owner:, **kw)
      super(
        owner: owner,
        target_team: :them,
        cooldown: 350,
        **kw
      )
    end
    
    def self.tower_name
      "Ballista"
    end
    
    def self.radius
      500
    end

    def self.image
      Res.image('ballista.png')
    end

    def self.gold_cost
      200
    end

    def self.description
      <<~END
        Launches collosal projectiles,
        dealing immense damage to the
        target and rendering them
        briefly immobile.
      END
    end

    def effect
      target = targets.sample
      target.damage(150)
      target.speed_buffs[self] = [0.05, 90] # Not completely immobile so can't stall forever!
      create_trail(to: target.position, colour: Gosu::Color::WHITE, intensity: 2)
      rotate_towards(target.position)

      Res.sample("audio/ballista_#{rand 1..3}.wav").play(0.4)
    end
  end
end
