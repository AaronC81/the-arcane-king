module GosuGameJam2
  module Res
    ROOT = File.join(__dir__, '..', 'res')

    def self.image(*name)
      @@loaded_images ||= {}
      @@loaded_images[name] ||= Gosu::Image.new(File.join(ROOT, *name))
      @@loaded_images[name]
    end

    def self.sample(*name)
      @@loaded_samples ||= {}
      @@loaded_samples[name] ||= Gosu::Sample.new(File.join(ROOT, *name))
      @@loaded_samples[name]
    end
  end
end
