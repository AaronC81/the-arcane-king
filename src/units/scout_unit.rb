require_relative 'unit'

module GosuGameJam2
  class ScoutUnit < Unit
    def initialize(team)
      super(
        team: team,
        speed: 2.0,
        max_health: 35,
        reward: 10,
      )
    end

    def self.spawn_cost
      # Become much cheaper as we go on, eventually ending up as virtually free
      [5 - ($world.wave / 2.5), 0.1].max
    end
  end
end
