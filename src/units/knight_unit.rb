require_relative 'unit'

module GosuGameJam2
  class KnightUnit < Unit
    def initialize(team)
      super(
        team: team,
        speed: 2.0,
        max_health: 100,
      )
    end

    def self.spawn_cost
      40
    end
  end
end