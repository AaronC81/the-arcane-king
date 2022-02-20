require_relative 'tower'

module GosuGameJam2
  class TrebuchetTower < Tower
    def initialize(owner:, **kw)
      super(
        owner: owner,
        target_team: :them,
        cooldown: 200,
        **kw
      )
    end
    
    def self.tower_name
      "Trebuchet"
    end
    
    def self.radius
      300
    end

    def self.description
      <<~END
        Slowly fires powerful
        projectiles across a long
        range to deal huge damage.
      END
    end

    def effect
      targets.sample.damage(40)
    end
  end
end
