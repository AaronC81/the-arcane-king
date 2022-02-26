require_relative 'unit'

module GosuGameJam2
  class KnightUnit < Unit
    def initialize(team)
      super(
        team: team,
        speed: 2.0,
        max_health: 130,
        reward: 25,
        animations: {
          walk: Animation.new([
            Res.image('units/knight.png'),
            Res.image('units/knight_walk_1.png'),
            Res.image('units/knight.png'),
            Res.image('units/knight_walk_2.png'),
            Res.image('units/knight.png'),
          ], 7)
        },
      )
      self.animation = :walk
    end

    def self.spawn_cost
      # The usual scaling system breaks down after around wave 20, so at that point we'll allow for
      # a ludicrous amount of knights
      if $world.wave >= 20
        1
      else
        40
      end
    end
  end
end
