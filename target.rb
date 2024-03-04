# 中性子
class Targets
  Target = Struct.new(:x, :y, :dead)

  attr_accessor :targets

  def initialize()
    @image = SDL::Surface.load("image/target.bmp")

    reset()
  end

  def reset()
    @targets = []
    @spawn_counter = 0
  end

  # Returns a random interger in [min, max]
  def randRange(min, max)
    return min + rand(max - min + 1)
  end

  def act(game)
    # 消去
    @targets.delete_if do |t|
      t.dead
    end
    
    # 生成
    if @spawn_counter <= 0
      x = randRange(X_MIN + 1, X_MAX - 1)
      y = randRange(Y_MIN, 15)
      isCollide = @targets.any? {|t| t.x == x and t.y == y}
      if not isCollide
        @targets.push(Target.new(x, y, false))
      end
      @spawn_counter = randRange($spawn_wait_last, [$spawn_wait_last, $spawn_wait_init - $score.score/$spawn_wait_step].max)
    else
      @spawn_counter -= 1
    end
  end

  def render(screen)
    @targets.each do |t|
      screen.put(@image, t.x*16, t.y*16)
    end
  end

  def checkCollision(b, game)
    @targets.each do |t|
      if b.x == t.x and b.y == t.y
        #game.addBullet(b.x, b.y, :DIRECTION_DOWN)
        game.addBullet(b.x, b.y, :DIRECTION_LEFT)
        game.addBullet(b.x, b.y, :DIRECTION_RIGHT)

        #b.y = Y_MAX + 1
        b.direction = :DIRECTION_DOWN
        b.is_dust = true

        t.dead = true
        $score.add(1)
        game.playHitSound()
      end
    end
  end

end
