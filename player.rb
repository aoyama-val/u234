# プレイヤー
class Player

  attr_reader :x, :y

  def initialize(x,y)
    @x, @y = x, y
    @image = SDL::Surface.load("image/player.bmp")
    @image_dead = SDL::Surface.load("image/dust.bmp")

    reset()
  end

  def reset()
    @dead = false
    @x = 18
    @y = Y_MAX
  end

  def act(input, game)
    #移動
    move(-1) if input.left
    move(+1) if input.right

    if input.fire
      game.addBullet(@x + 1, @y - 1, :DIRECTION_UP)
    end
  end

  def render(screen)
    if dead?
      for i in 0...3
        screen.put(@image_dead, (@x+i)*16, @y*16)
      end
    else
      screen.put(@image, @x*16, @y*16)
    end
  end

  def move(dist)
    @x += dist
    @x = X_MAX - 2 if @x > X_MAX - 2
    @x = X_MIN if @x < X_MIN
  end

  def dead?()
    return @dead
  end

  def die()
    @dead = true
  end

  def checkCollision(bullet)
    if (@x <= bullet.x and bullet.x <= @x + 2) and (bullet.y == @y)
      die()
    end
  end

end
