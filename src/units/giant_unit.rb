require_relative 'unit'

module GosuGameJam2
  class GiantUnit < Unit
    def initialize(team)
      super(
        team: team,
        speed: 1.2,
        max_health: 500,
      )
    end

    def self.spawn_cost
      100
    end
  end
end
