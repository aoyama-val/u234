
class Bullets
  Bullet = Struct.new(:x, :y, :direction, :is_dust)

  attr_accessor :Bullet
  attr_accessor :bullets

  def initialize
    @img_up    = SDL::Surface.loadBMP("image/up.bmp")
    @img_down  = SDL::Surface.loadBMP("image/down.bmp")
    @img_right = SDL::Surface.loadBMP("image/right.bmp")
    @img_left  = SDL::Surface.loadBMP("image/left.bmp")
    @img_dust  = SDL::Surface.loadBMP("image/dust.bmp")

    reset()
  end

  def reset()
    @bullets = []
  end

  def act(game)
    @bullets.each do |bullet|
      case bullet.direction
      when :DIRECTION_UP
        if bullet.y == Y_MIN
          bullet.direction = :DIRECTION_DOWN
          bullet.y += 1
        else
          bullet.y -= 1
        end
      when :DIRECTION_DOWN
        bullet.y += 1
      when :DIRECTION_RIGHT
        if bullet.x == X_MAX
          bullet.direction = :DIRECTION_LEFT
          bullet.x -= 1
        else
          bullet.x += 1
        end
      when :DIRECTION_LEFT
        if bullet.x == X_MIN
          bullet.direction = :DIRECTION_RIGHT
          bullet.x += 1
        else
          bullet.x -= 1
        end
      end
    end
      
    #clear()
  end

  def clear()
    #消去
    @bullets.delete_if do |bullet|
      bullet.y > Y_MAX
    end
  end

  def render(screen)
    @bullets.each do |bullet|
      if bullet.is_dust
        screen.put(@img_dust, bullet.x*16, bullet.y*16)
      else
        case bullet.direction
        when :DIRECTION_UP
          screen.put(@img_up, bullet.x*16, bullet.y*16)
        when :DIRECTION_DOWN
          screen.put(@img_down, bullet.x*16, bullet.y*16)
        when :DIRECTION_RIGHT
          screen.put(@img_right, bullet.x*16, bullet.y*16)
        when :DIRECTION_LEFT
          screen.put(@img_left, bullet.x*16, bullet.y*16)
        end
      end
    end
  end

  def add_spawned(bullets)
    # 発射キーを押しっぱなしにしたとき、後から出た弾が見えるように
    # この順番で連結する
    @bullets = bullets + @bullets
  end

  def checkCollision()
    for i in 0...(@bullets.length)
      for j in 0...(@bullets.length)
        b1 = @bullets[i]
        b2 = @bullets[j]
        if b1.x == b2.x and b1.y == b2.y and
          ( (b1.direction == :DIRECTION_LEFT and b2.direction == :DIRECTION_RIGHT) or
            (b1.direction == :DIRECTION_RIGHT and b2.direction == :DIRECTION_LEFT) )
            b1.y = Y_MAX + 1
            b2.y = Y_MAX + 1
        end
      end
    end
  end

end
