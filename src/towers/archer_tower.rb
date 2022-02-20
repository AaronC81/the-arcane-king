require_relative 'tower'

module GosuGameJam2
  class ArcherTower < Tower
    def initialize(owner:, **kw)
      super(
        name: "Archer",
        owner: owner,
        target_team: :them,
        cooldown: 30,
        **kw
      )
    end

    def self.radius
      100
    end

    def effect
      targets.sample.damage(10)
    end
  end
end
