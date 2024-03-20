class GamesController < ApplicationController
  def new
    if Game.last.nil?
      @game = Game.new(white: current_user)
    elsif Game.last.black_id.nil?
      @game = Game.last
      @game.black = current_user
    else
      @game = Game.new(white: current_user)
    end
    
    @chatroom = Chatroom.new
    @chatroom.game = @game

    @game.save

    redirect_to game_path(@game)
  end

  def show
    @game = Game.find(params[:id])

    if @game.black.present?
      GameChannel.broadcast_to(
        @game,
        @game.black.profile.username
      )
    end

    @chatroom = @game.chatroom
    @chatroom.save
  end
end
