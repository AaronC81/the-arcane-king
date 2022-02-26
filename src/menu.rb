module TheArcaneKing
  module Menu
    def self.draw_main_menu
      # Black out screen
      Gosu.draw_rect(0, 0, WIDTH, HEIGHT, Gosu::Color::BLACK)

      # Draw logo and subtitles
      Res.image('logo/logo.png').draw(350, 100, 0)
      ['Created by Aaron Christiansen', 'for Gosu Game Jam 2'].each.with_index do |subtitle, i|
        subtitle_length = $large_font.text_width(subtitle)
        $large_font.draw_text(subtitle, (WIDTH - subtitle_length) / 2, 400 + i * 45, 100, 1, 1, Gosu::Color::WHITE)
      end

      # Begin prompt
      Res.image('left_click.png').draw(740, 603, 0)
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

    def self.draw_text_on_box(x, y, text)
      lines = text.split("\n")
      text_width = lines.map { |l| $large_font.text_width(l) }.max
      text_height = lines.length * $large_font.height

      padding = 10
      Gosu.draw_rect(
        x, y,
        text_width + padding * 2, text_height + padding * 2,
        Gosu::Color.argb(0xDD, 0x00, 0x00, 0x00), 1000,
      )
      $large_font.draw_text(
        text, x + padding, y + padding, 1000, 1, 1,
        Gosu::Color::WHITE,
      )
    end

    def self.draw_tutorial_overlay
      draw_text_on_box(300, 20, "Your Majesty! Our kingdom is under attack!")
      draw_text_on_box(900, 60, "When the attackers reach\nour castle, they'll damage it.")
      draw_text_on_box(910, 200, "Construct defences for\nour army, so that we\nwill defeat them!")
      draw_text_on_box(910, 420, "You can also use your\narcane ability to cast\ndeadly spells at our foes\nduring battle.")
      draw_text_on_box(910, 680, "Defeating enemies will\ngrant you gold to buy\ndefences or spell charges.")

      draw_text_on_box(500, 800, "            Dismiss tutorial")
      Res.image('left_click.png').draw(515, 815, 10000)
    end
  end
end
