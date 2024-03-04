class Background
  def initialize
    @image_wall = SDL::Surface.loadBMP("image/wall.bmp")
    @image_back = SDL::Surface.loadBMP("image/back.bmp")
  end

  def render(screen)
    for i in 1..22
      screen.put(@image_wall, (X_MIN-1)*16, i*16)
      screen.put(@image_wall, (X_MAX+1)*16, i*16)
    end
    for i in X_MIN..X_MAX
      screen.put(@image_wall, i*16, 1*16)
    end

    for i in 0...(SCREEN_W/16)
      screen.put(@image_back, i*16, (Y_MAX+1)*16)
    end
  end
end

