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
      # Don't spawn brutes until after the first few waves - one enemy makes for a boring wave 1
      if $world.wave > 3
        30
      else
        100000
      end
    end
  end
end
