require_relative 'unit'

module GosuGameJam2
  class ScoutUnit < Unit
    def initialize(team)
      super(
        team: team,
        speed: 2.0,
        max_health: 30,
      )
    end

    def self.spawn_cost
      5
    end
  end
end
