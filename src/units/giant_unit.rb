require_relative 'unit'

module TheArcaneKing
  class GiantUnit < Unit
    def initialize(team)
      super(
        team: team,
        speed: 1.2,
        max_health: 400,
        reward: 60,
        animations: {
          walk: Animation.new([
            Res.image('units/giant.png'),
            Res.image('units/giant_walk_1.png'),
            Res.image('units/giant.png'),
            Res.image('units/giant_walk_2.png'),
            Res.image('units/giant.png'),
          ], 10)
        },
      )
      self.animation = :walk
    end

    def self.spawn_cost
      # Don't spawn giants until after the first few waves - they're way too powerful if you start
      # too slow
      if $world.wave > 5
        90
      else
        100000
      end
    end
  end
end
