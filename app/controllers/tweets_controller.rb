class TweetsController < ApplicationController
  def new
    @tweet = Tweet.new # 新規投稿用の空のインスタンス
  end

  def index
    @tweets = Tweet.all
  end

  def show
    @tweet = Tweet.find(params[:id])
  end

  def create
  end
end
