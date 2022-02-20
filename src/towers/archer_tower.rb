require_relative 'tower'

module GosuGameJam2
  class ArcherTower < Tower
    def initialize(owner:, **kw)
      super(
        name: "Archer",
        radius: 100,
        owner: owner,
        target_team: :them,
        cooldown: 30,
        **kw
      )
    end

    def effect
      targets.sample.health -= 10
    end
  end
end
