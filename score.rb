class Score
  SCOREFILE = "score.dat"

  def initialize
    #ハイスコアのロード(ファイルがあれば)
    if File.exist?(SCOREFILE)
      @highscore = File.open(SCOREFILE,"rb"){|f| Marshal.load(f)}
    else
      @highscore = 0
    end
    @score = 0
  end
  attr_reader :score, :highscore

  #スコアのリセット(と、ハイスコアの更新)
  def reset
    if @highscore < @score
      @highscore = @score
    end
    @score = 0
  end
  
  #ハイスコアのセーブ
  def save
    data = @highscore
    File.open(SCOREFILE,"wb"){|f| Marshal.dump(data,f)}
  end

  def add(value)
    @score += value
  end
end

