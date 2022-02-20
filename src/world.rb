module GosuGameJam2
  class World
    def initialize
      @units = []
      @towers = []
    end

    # All units in the world.
    attr_accessor :units

    # All towers in the world.
    attr_accessor :towers

    # The tower class which is currently being placed.
    attr_accessor :placing_tower

    # Finds and returns all units matching the given criteria:
    #   - `team:`, required, which team the units belong to.
    #   - `radius:`, given as [point, radius], filters only to units which are less than `radius`
    #     away from `point`.
    def find_units(team:, radius: nil)
      units
        .filter { |u| u.team == team }
        .filter do |u|
          if radius
            u.position.distance(radius[0]) <= radius[1]
          else
            true
          end
        end
    end
  end
end
