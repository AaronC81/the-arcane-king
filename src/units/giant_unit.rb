require_relative 'unit'

module GosuGameJam2
  class GiantUnit < Unit
    def initialize(team)
      super(
        team: team,
        speed: 1.2,
        max_health: 400,
        reward: 60,
      )
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
