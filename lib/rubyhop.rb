require "gosu"

def get_my_file file
  "#{File.dirname(__FILE__)}/#{file}"
end

class Player
  attr_accessor :x, :y
  def initialize window
    @window = window
    @alive  = true
    # position
    @x = window.width/2
    @y = window.height/2
    @velocity = 0.0
    @gravity  = -0.25
    @hop      = 7.5
    # sounds
    @sound    = Gosu::Sample.new @window, get_my_file("hop.mp3")
    @gameover = Gosu::Sample.new @window, get_my_file("gameover.mp3")
    # images
    @rise = Gosu::Image.new window, get_my_file("rubyguy-rise.png")
    @fall = Gosu::Image.new window, get_my_file("rubyguy-fall.png")
    @dead = Gosu::Image.new window, get_my_file("rubyguy-dead.png")
  end
  def hop
    if @alive
      @sound.play
      @velocity += @hop
    end
  end
  def die!
    if @alive
      # Set velocity to one last hop
      @velocity = 5.0
      @gameover.play
      @alive = false
    end
  end
  def update
    @velocity += @gravity
    @y -= @velocity
    if @alive && (@y < 32 || @y > @window.height - 32)

    end
    if @y > 5000
      # kick out to loading screen to try again?
      @window.close
    end
  end
  def draw
    image.draw @x - 32, @y - 32, 1000 - @x
  end
  def image
    if @alive
      if @velocity >= 0
        @rise
      else
        @fall
      end
    else
      @dead
    end
  end
end

class Hoop
  attr_accessor :x, :y
  def initialize window
    @window   = window
    @hoop  = Gosu::Image.new window, get_my_file("hoop.png")
    # center of screen
    @movement = 2
    @x = @y = 0
    reset_position!
  end
  def reset_position!
    @x += 1200
    @y = rand 150..500
  end
  def miss player
    if (@x - player.x).abs < 12 &&
       (@y - player.y).abs > 72
       # the player missed the hoop
       return true
     end
     false
  end
  def update
    reset_position! if @x < -200
    @movement += 0.003
    @x -= @movement
  end
  def draw
    @hoop.draw @x - 66, @y - 98, 1000 - @x
  end
end

class RubyhopGame < Gosu::Window
  VERSION = "1.0.0"
  def initialize width=800, height=600, fullscreen=false
    super
    self.caption = "Ruby Hop"
    @music = Gosu::Song.new self, get_my_file("music.mp3")
    @music.play true
    @background = Gosu::Image.new self, get_my_file("background.png")
    @player = Player.new self
    @hoops = 6.times.map { Hoop.new self }
    init_hoops!
  end

  def init_hoops!
    hoop_start = 600
    @hoops.each do |hoop|
      hoop_start += 200
      hoop.reset_position!
      hoop.x = hoop_start
    end
  end

  def button_down id
    close       if id == Gosu::KbEscape
    @player.hop if id == Gosu::KbSpace
  end

  def update
    @player.update
    @hoops.each do |hoop|
      hoop.update
      @player.die! if hoop.miss @player
    end
  end

  def draw
    @background.draw 0, 0, 0
    @player.draw
    @hoops.each &:draw
  end
end
