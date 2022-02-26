require_relative 'unit'

module TheArcaneKing
  class InvaderUnit < Unit
    def initialize(team)
      super(
        team: team,
        speed: 2.6,
        max_health: 110,
        reward: 25,
        animations: {
          walk: Animation.new([
            Res.image('units/invader.png'),
            Res.image('units/invader_walk_1.png'),
            Res.image('units/invader.png'),
            Res.image('units/invader_walk_2.png'),
            Res.image('units/invader.png'),
          ], 5)
        },
      )
      self.animation = :walk
    end

    def self.spawn_cost
      40
    end
  end
end
