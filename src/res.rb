module GosuGameJam2
  module Res
    ROOT = File.join(__dir__, '..', 'res')

    def self.image(*name)
      @@loaded_images ||= {}
      @@loaded_images[name] ||= Gosu::Image.new(File.join(ROOT, *name))
      @@loaded_images[name]
    end
  end
end
