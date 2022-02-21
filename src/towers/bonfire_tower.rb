require_relative 'tower'

module GosuGameJam2
  class BonfireTower < Tower
    def initialize(owner:, **kw)
      super(
        owner: owner,
        target_team: :them,
        cooldown: 1,
        **kw
      )
    end

    def self.tower_name
      "Bonfire"
    end

    def self.radius
      100
    end
    
    def self.description
      <<~END
        Produces a thick fog in a
        small area, significantly
        slowing down all enemies
        in its entire area.
      END
    end

    def effect
      targets.each do |target|
        target.speed_buffs[self] = [0.65, 5]
      end
    end
  end
end
