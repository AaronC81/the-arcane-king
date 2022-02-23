module GosuGameJam2
  class World
    def initialize
      @units = []
      @towers = []
      @entities = []

      @max_castle_health = 2000
      @castle_health = @max_castle_health
    end

    # All units in the world.
    attr_accessor :units

    # All towers in the world.
    attr_accessor :towers

    # Other entities which need to be ticked and drawn.
    attr_accessor :entities

    # The tower class which is currently being placed.
    attr_accessor :placing_tower

    # The path which units will follow.
    attr_accessor :path

    # The position where the path starts.
    attr_accessor :path_start

    # The maximum health of the friendly castle.
    attr_accessor :max_castle_health

    # The remaining health of the friendly castle.
    attr_accessor :castle_health

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

    # Yields the given block with each of the lines which make up the path, in the form [start, end]
    # where both are points.
    def trace_path(with_direction: false)
      line_curr_point = path_start.clone
      path.each do |(pos, dir)|
        pos = path_component_to_coordinate([pos, dir])
        new_point = Point.new(
          (dir == :east || dir == :west) ? pos : line_curr_point.x,
          (dir == :north || dir == :south) ? pos : line_curr_point.y,
        )

        points = [line_curr_point, new_point].map(&:clone)
        if with_direction
          yield [*points, dir]
        else
          yield points
        end

        line_curr_point = new_point
      end
    end

    # Converts one component of a path to a coordinate, on the axis which the path component moves
    # along.
    def path_component_to_coordinate(comp)
      pos, dir = *comp
      case dir
      when :east, :west
        pos * TILE_SIZE
      when :north, :south
        HEIGHT / 2 - pos * TILE_SIZE
      end
    end
  end
end
