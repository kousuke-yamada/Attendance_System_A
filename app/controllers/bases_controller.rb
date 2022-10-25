class BasesController < ApplicationController
  before_action :set_base, only: [:show, :edit, :update, :destroy]
  before_action :admin_user

  def index
    @bases = Base.all
  end

  def new
    @base = Base.new
  end

  def create
    @base = Base.new(base_params)
    if @base.save
      flash[:success] = "拠点情報を新規追加しました。"
      redirect_to bases_url
    else
      render :new
    end
  end

  def show
    render :edit
  end

  def edit
  end

  def update
    if @base.update_attributes(base_params)
      flash[:success] = "拠点情報を更新しました。"
      redirect_to bases_url
    else
      render :edit
    end
  end

  def destroy
    @base.destroy
    flash[:success] = "#{@base.basename}のデータを削除しました。"
    redirect_to bases_url
  end

  private

    def base_params
      params.require(:base).permit(:baseno, :basename, :basekind)
    end

    def set_base
      @base = Base.find(params[:id])
    end
end
