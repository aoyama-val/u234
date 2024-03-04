class Image
  def initialize(name)
    @image = SDL::Surface.loadBMP("image/#{name}.bmp")
  end

  def render(screen)
  end
end

