class NumberFont
  def initialize
    image = SDL::Surface.loadBMP("image/numbers.bmp")
    @images = []
    for i in 0..9
      @images.push(image.copy_rect(8*i, 0, 8, 16).display_format)
    end
  end

  def putstr(screen, x, y, str)
    str.each_byte do |b|
      if 0x30 <= b and b <= 0x39
        screen.put(@images[b - 0x30], x, y)
        x += 8
      else
        x += 8
      end
    end
  end
end
