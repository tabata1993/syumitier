class GroupsController < ApplicationController
  before_action :login_check,only:[:show,:new,:confirm,:create,:edit,:update,:destroy]
  before_action :set_group,only:[:show,:edit,:manager_edit,:update,:destroy]
  before_action :other_than_manager_edit_block,only:[:edit,:manager_edit,:destroy]

  def home
    index
  end

  def index
    @groups = Group.all.order('updated_at DESC')
  end

  def show
    @join = current_user.joins.find_by(group_id: @group.id)
    @manager_user = @group.user
    @member_user = @group.join_users
  end

  def new
    if params[:back]
      @group = Group.new(group_params)
    else
      @group = Group.new
    end
  end

  def confirm
    @group = Group.new(group_params)
    @group.user_id = current_user.id
    render :new if @group.invalid?
  end

  def create
    @group = Group.new(group_params)
    if @group.save
      Join.create(user_id: current_user.id , group_id: @group.id)
      redirect_to groups_path,notice:"サークルを作成しました。"
    else
      render new_group_path
    end
  end

  def edit
  end

  def manager_edit
    @member_user = @group.join_users
    @manager_user = @group.user
  end

  def update
    if @group.update(group_params)
      redirect_to group_path(params[:id]),notice:"サークル情報を変更しました！"
    else
      render 'edit'
    end
  end

  def destroy
    @group.destroy
    redirect_to groups_path,notice:"グループを削除しました。"
  end

private
  def group_params
    params.require(:group).permit(:name,:user_id,:place,:time,:content,group_attributes: [:user_id,:group_id])
  end

  def set_group
    @group = Group.find(params[:id])
  end

  def other_than_manager_edit_block
    unless current_user == User.find_by(id: @group.user_id)
      redirect_to group_path(params[:id]),notice:"サークル情報の編集は代表者のみ可能です。"
    end
  end

end
