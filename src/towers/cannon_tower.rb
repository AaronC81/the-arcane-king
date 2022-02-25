require_relative 'tower'

module GosuGameJam2
  class CannonTower < Tower
    EXPLOSION_RADIUS = 100
    EXPLOSION_COLOUR = Gosu::Color.argb(0xFF, 246, 165, 11)

    def initialize(owner:, **kw)
      super(
        owner: owner,
        target_team: :them,
        cooldown: 150,
        **kw
      )
    end
    
    def self.tower_name
      "Cannon"
    end
    
    def self.radius
      250
    end

    def self.image
      Res.image('cannon.png')
    end

    def self.description
      <<~END
        Launches explosive
        cannonballs which deal
        damage in an area around
        the target.
      END
    end

    def self.gold_cost
      500
    end

    def effect
      primary_target = targets.sample
      $world.find_units(team: :enemy, radius: [primary_target.position, EXPLOSION_RADIUS]).each do |t|
        t.damage(40)
      end
      create_trail(
        to: primary_target.position,
        colour: EXPLOSION_COLOUR,
        intensity: 1,
        explosion: EXPLOSION_RADIUS
      )
      rotate_towards(primary_target.position)

      Res.sample("audio/cannon.wav").play(0.25)
    end
  end
end
