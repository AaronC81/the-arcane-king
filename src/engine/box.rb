module TheArcaneKing
  class Box
    def initialize(origin, width, height)
      @origin = origin
      @width = width
      @height = height
      $all_boxes << self if ENV['DEBUG_BOXES']
    end 

    attr_accessor :origin, :width, :height

    def overlaps?(other)
      self.origin.x < other.origin.x + other.width \
      && other.origin.x < self.origin.x + self.width \
      && self.origin.y < other.origin.y + other.height \
      && other.origin.y < self.origin.y + self.height
    end
  end 
end
