#!/usr/bin/ruby

require 'green_shoes'
require 'cgi/util'

## Parse command-line arguments (they're file paths)

Audio = ARGV[0]
 Song = CGI::escapeHTML File.basename ARGV[1]
 Root = File.dirname ARGV[1]
Image = Root + "/.cover-image.png"
Album = CGI::escapeHTML File.basename Root

ImageMargin = 13
 ImageWidth = 210
 TextMargin = 13
 TextHeight = 13 + 2*20 + 10 + 5 + 20 + 0

Width = ImageWidth + 2*ImageMargin

if File.exist? Image
then Height = ImageWidth + 1*ImageMargin + TextHeight
else Height = TextHeight
end


## Here's the UI

Shoes.app(
  title:      "Music",
  width:       Width,
  height:      Height,
  undecorated: true
) do

  background "#222"

  #### Elements ####

  # Album art
  if File.exist? Image
  then @i = image(
         Image,
         width:  ImageWidth,
         height: ImageWidth,
         margin: [ImageMargin, ImageMargin, ImageMargin, 0]
       )
  end

  # Artist, album and track name text
  @s = stack width: Width do
    inscription(
      Album,
      stroke: "#666",
      margin: [TextMargin, 13, TextMargin, 0],
      wrap:   "trim",
      width:   Width - 2*TextMargin,
      family: "Ubuntu"
    )
    inscription(
      Song,
      stroke: "#ccc",
      margin: [TextMargin, 0, TextMargin, 10],
      wrap:   "trim",
      width:   Width - 2*TextMargin,
      family: "Ubuntu"
    )
  end
  
  # Controls
  flow(
    width: Width,
    margin: [0, 0, 0, 0]
  ) do
    background "#2a2a2a"
    
    @pause = flow width: Width - TextMargin - 2*20 do
      inscription(
        "⏸",
        stroke: "#666",
        family: "Ubuntu",
        margin: [TextMargin, 5, 0, 0]
      )
    end
    @folder = flow width: 20 do
      inscription(
        "🖿",
        stroke: "#666",
        family: "Ubuntu",
        align:  "right",
        margin: [0, 5, 0, 0]
      )
    end
    @stop = flow width: 20 do
      inscription(
        "⏹",
        stroke: "#666",
        family: "Ubuntu",
        align:  "right",
        margin: [0, 5, TextMargin, 0]
      )
    end
  end
  
  # The audio player
  @player = audio Audio
  @player.play
  
  
  #### Actions ####

  # Control buttons
  @stop.click do exit end
  @folder.click do `xdg-open "#{Root}"` end
  # TODO: play/pause
  
  # Dragging moves the window
  motion do |left, top|
    button, x, y = self.mouse
    if button == 1
      if @dragging
        root_x, root_y = self.win.position
        self.win.move(
          root_x + (x - @ix),
          root_y + (y - @iy)
        )
      else
        @dragging = true
        @ix = x
        @iy = y
      end
    else
      @dragging = false
    end
  end

end
