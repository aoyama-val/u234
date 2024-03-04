#
# Uranium234
# (c)2010, AOYAMA Shotaro
#
require 'sdl'
require 'lib/fpstimer.rb'
require 'lib/input.rb'
require 'score.rb'
require 'player.rb'
require 'bullet.rb'
require 'background.rb'
require 'target.rb'
require 'numberfont.rb'
require 'config.rb'

def clamp(min, value, max)
  if value < min 
    return min
  elsif max < value
    return max
  else
    return value
  end
end

$spawn_wait_init = clamp(1, $spawn_wait_init, 999)
$spawn_wait_last = clamp(1, $spawn_wait_last, 999)
$spawn_wait_step = clamp(1, $spawn_wait_step, 999)

SCREEN_W = 640
SCREEN_H = 400
X_MIN = 2
X_MAX = SCREEN_W / 16 - 3
Y_MIN = 2
Y_MAX = SCREEN_H / 16 - 3

FPS = 30

#キー定義
class Input
  define_key SDL::Key::ESCAPE, :exit
  define_key SDL::Key::LEFT,   :left
  define_key SDL::Key::RIGHT,  :right
  define_key SDL::Key::Y, :ok
  define_key SDL::Key::N, :no
  define_key SDL::Key::LSHIFT, :fire
  define_pad_button 0, :fire
end

class Game

  def main

    if ARGV.include?('-nosound')
      @playSound = false
    else
      @playSound = true
    end

    # 初期化
    if @playSound
      SDL.init(SDL::INIT_VIDEO|SDL::INIT_AUDIO|SDL::INIT_JOYSTICK)
      SDL::Mixer.open
    else
      SDL.init(SDL::INIT_VIDEO|SDL::INIT_JOYSTICK)
    end
    SDL::TTF.init
    SDL::WM.set_caption("U234", "")

    # 画面の初期化
    if defined?(SDL::RELEASE_MODE)
      # game.exeから起動したとき
      SDL::Mouse.hide
      @screen = SDL.set_video_mode(SCREEN_W, SCREEN_H, 16, SDL::HWSURFACE|SDL::DOUBLEBUF|SDL::FULLSCREEN)
    else
      # debug.exeから起動したとき
      @screen = SDL.set_video_mode(SCREEN_W, SCREEN_H, 16, SDL::SWSURFACE|SDL::DOUBLEBUF)
    end

    # オブジェクトの生成
    $score = Score.new

    @title = SDL::Surface.load("image/title.bmp")

    @input = Input.new
    @font = SDL::TTF.open("image/boxfont2.ttf",20)
    @numberFont = NumberFont.new

    if @playSound
      @sound_crash = SDL::Mixer::Wave.load("sound/crash.wav")
      @sound_hit   = SDL::Mixer::Wave.load("sound/hit.wav")
    end
    @playHitSoundCounter = 0

    @player      = Player.new(3, Y_MAX)
    @targets     = Targets.new
    @bullets     = Bullets.new
    @bullets_spawned = []
    @background  = Background.new

    @state = :playing   # 最初のシーン

    @frame = 0

    # メインループ
    timer = FPSTimerLight.new(FPS, 10, 15)
    timer.reset
    loop do  
      @input.poll             #入力
      break if @input[:exit]  #  ESCAPE押されたら終了
      break if (@input[:no] and @state == :gameover)

      act                     #動作
      render                  #描画
      timer.wait_frame{ @screen.flip } #待つ
      @frame += 1
    end

    #終了
    $score.save
  end

  def act
    case @state
    when :playing
      act_playing
    when :gameover
      act_gameover
    end
  end

  # ゲーム中 (爆弾に当たったらGAME OVERに)
  def act_playing
    if @playHitSoundCounter > 0
      @playHitSoundCounter -= 1
    end
    @bullets.add_spawned(@bullets_spawned)
    @bullets_spawned.clear()

    @player.act(@input, self)
    @bullets.act(self)
    @targets.act(self)

    @bullets.bullets.each do |b|
      @player.checkCollision(b)
      @targets.checkCollision(b, self)
    end
    @bullets.checkCollision()

    @bullets.clear()

    crash = @player.dead?

    if crash 
      @state = :gameover
      if @playSound
        trycount = 0
        begin
          trycount += 1
          SDL::Mixer.play_channel(-1,@sound_crash,0) if @playSound
          rescue
          if trycount < 5
            SDL.delay(100)
            retry
          end
        end
        #SDL::Mixer.halt_music
      end
      @time = 0
    end
  end

  # GAME OVER
  def act_gameover
    if @input.ok
      @state = :playing
      @player.reset
      @bullets_spawned.clear()
      @bullets.reset
      @targets.reset
      $score.reset
    end
  end

  def render
    #背景の描画
    @screen.fill_rect(0,0,  SCREEN_W,SCREEN_H, [0,0,0])
    @screen.put(@title, 16, 0)
    @background.render(@screen)

    #キャラクターの描画（重なったとき、下の方が優先される！）
    @bullets.render(@screen)
    @targets.render(@screen)
    @player.render(@screen)

    #スコアの描画
    @numberFont.putstr(@screen, 16*18, 0, "%8d" % [$score.highscore * 1000])
    @numberFont.putstr(@screen, 16*32, 0, "%8d" % [$score.score * 1000])

    #メッセージの描画
    case @state
    when :gameover
      @font.drawBlendedUTF8(@screen,"MELT DOWN",260,170, 255,0,0)
      @font.drawBlendedUTF8(@screen,"RETRY Y/N",260,200, 255,0,0)
    end
  end

  def addBullet(x, y, direction=:DIRECTION_UP)
    @bullets_spawned.push(Bullets::Bullet.new(x, y, direction))
  end

  def playHitSound()
    if @playSound and @playHitSoundCounter == 0
      SDL::Mixer.play_channel(-1,@sound_hit,0)
      @playHitSoundCounter= 5
    end
  end

end


#実行！
Game.new.main
