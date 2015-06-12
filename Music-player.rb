#!/usr/bin/ruby

require 'green_shoes'
require 'cgi/util'

## Parse command-line arguments (they're file paths)

Audio = ARGV[0]
 Song = CGI::escapeHTML File.basename ARGV[1]
 Root = File.dirname ARGV[1]
Image = Root + "/.cover-image.png"
Album = CGI::escapeHTML File.basename Root

ImageMargin = 10
ImageWidth = 200
TextMargin = 13
TextHeight = 58

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

  background "#333"

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

    background "#222"
    inscription(
      Album,
      stroke: "#666",
      margin: [TextMargin, 10, TextMargin, 0],
      wrap:   "trim",
      width:   Width - 2*TextMargin,
      family: "Ubuntu"
    )
    inscription(
      Song,
      stroke: "#ccc",
      margin: [TextMargin, 0, TextMargin, 8],
      wrap:   "trim",
      width:   Width - 2*TextMargin,
      family: "Ubuntu"
    )

  end
  
  # The audio player
  @player = audio Audio
  @player.play
  
  
  #### Actions ####

  # Clicking on the text block opens a file browser
  @s.click do `xdg-open "#{Root}"` end
  
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
  
  # Right-clicking quits
  self.click do |button, left, right|
    if button == 3 then exit end
  end

end
