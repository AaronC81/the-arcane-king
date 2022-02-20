require 'gosu'

Gosu::enable_undocumented_retrofication

class GameWindow < Gosu::Window
  def initialize
    super(1600, 900)
  end

  def update
    if Gosu.button_down?(Gosu::KB_F)
      self.fullscreen = !fullscreen?
      sleep 1 # really rubbish debounce
    end
  end

  def draw

  end
end

GameWindow.new.show
