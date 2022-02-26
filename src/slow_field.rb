module TheArcaneKing
  class SlowField < Entity
    def initialize(**kw)
      super
      # Last 20 seconds (* 60 ticks per second)
      @lifespan = 20 * 60
    end

    def draw
      radius, colour = World::SPELL_RADII[:slow]
      Gosu.draw_circle(position.x, position.y, radius, colour, 80, 3)
    end

    def tick
      radius, _ = World::SPELL_RADII[:slow]
      
      # Decay lifespan, and destroy if passed or wave is finished
      @lifespan -= 1
      if @lifespan <= 0 || !$world.wave_in_progress?
        $world.entities.delete(self)
      end

      # Slow nearby units
      targets = $world.find_units(team: :enemy, radius: [position, radius])
      targets.each do |t|
        t.speed_buffs[self] = [0.5, 5]
      end
    end
  end
end
