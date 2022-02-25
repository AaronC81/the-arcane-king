require_relative 'unit'

module GosuGameJam2
  class CavalryUnit < Unit
    def initialize(team)
      super(
        team: team,
        speed: 3.5,
        max_health: 60,
        reward: 35,
      )
    end

    def self.spawn_cost
      70
    end
  end
end
