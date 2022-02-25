require_relative 'tower'

module GosuGameJam2
  class WatchtowerTower < Tower
    def initialize(owner:, **kw)
      super(
        owner: owner,
        target_team: :them,
        cooldown: 1,
        **kw
      )
    end

    def self.tower_name
      "Watchtower"
    end

    def self.radius
      100
    end
    
    def self.description
      <<~END
        Slows down all enemies
        in its radius, allowing
        towers more time to
        attack.
      END
    end

    def self.image
      Res.image('watchtower.png')
    end

    def self.gold_cost
      25
    end

    def effect
      targets.each do |target|
        target.speed_buffs[self] = [0.65, 5]
      end
    end
  end
end
