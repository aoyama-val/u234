class Image
  def initialize(name)
    @image = SDL::Surface.load("image/#{name}.bmp")
  end

  def render(screen)
  end
end

