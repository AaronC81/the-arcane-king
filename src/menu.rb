module TheArcaneKing
  module Menu
    def self.draw_main_menu
      # Black out screen
      Gosu.draw_rect(0, 0, WIDTH, HEIGHT, Gosu::Color::BLACK)

      # Draw logo and subtitles
      Res.image('logo/logo.png').draw(350, 100)
      ['Created by Aaron Christiansen', 'for Gosu Game Jam 2'].each.with_index do |subtitle, i|
        subtitle_length = $large_font.text_width(subtitle)
        $large_font.draw_text(subtitle, (WIDTH - subtitle_length) / 2, 400 + i * 45, 100, 1, 1, Gosu::Color::WHITE)
      end

      # Begin prompt
      Res.image('left_click.png').draw(740, 603)
      $large_font.draw_text("to begin!", 780, 597, 100, 1, 1, Gosu::Color::WHITE)

      # Font hint
      $regular_font_plain.draw_text("Press F to toggle\nalternative font", 1450, 850, 100, 1, 1, Gosu::Color::WHITE)

      # Credits
      $regular_font.draw_text(<<~END, 20, 700, 100, 1, 1, Gosu::Color::WHITE)
        Tower & Path Graphics: Kenney
        Grass Texture: LuminousDragonGames (OpenGameArt.org)
        SFX: Still North Media, Iwan "Qubodup" Gabovitch (Freesound), cetsoundcrew (Freesound),
                  Isaac200000 (Freesound), j1987 (Freesound), SilverIllusionist (Freesound),
                  RunnerPack (Freesound), RICHERlandTV (Freesound), bubaproducer (Freesound)
        Battle Music: playonloop.com
        Building Music: RandomMind (OpenGameArt.org)
      END
    end
  end
end
