require_relative 'unit'

module TheArcaneKing
  class CavalryUnit < Unit
    def initialize(team)
      super(
        team: team,
        speed: 3.5,
        max_health: 80,
        reward: 35,
        animations: {
          walk: Animation.new([
            Res.image('units/cavalry_walk_1.png'),
            Res.image('units/cavalry_walk_2.png'),
            Res.image('units/cavalry_walk_3.png'),
            Res.image('units/cavalry_walk_4.png'),
          ], 7)
        },
      )
      self.animation = :walk
    end

    def self.spawn_cost
      70
    end
  end
end
