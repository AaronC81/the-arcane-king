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
      100
    end

    def self.description
      <<~END
        Periodically deals damage
        to one target in a small
        range.
      END
    end

    def effect
      targets.sample.damage(10)
    end
  end
end
