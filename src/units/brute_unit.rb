require_relative 'unit'

module GosuGameJam2
  class BruteUnit < Unit
    def initialize(team)
      super(
        team: team,
        speed: 1.4,
        max_health: 150,
        reward: 20,
      )
    end

    def self.spawn_cost
      25
    end
  end
end
