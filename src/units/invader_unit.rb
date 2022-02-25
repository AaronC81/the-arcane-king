require_relative 'unit'

module GosuGameJam2
  class InvaderUnit < Unit
    def initialize(team)
      super(
        team: team,
        speed: 2.6,
        max_health: 60,
        reward: 25,
      )
    end

    def self.spawn_cost
      40
    end
  end
end
