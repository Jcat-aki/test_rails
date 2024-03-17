# frozen_string_literal: true

module SessionsHelper
  # 渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id
  end

  # MEMO: 本当は一時的なToken などを渡して更新する方がよし
  def current_user
    return nil unless session[:user_id]

    User.find_by(id: session[:user_id])
  end

  def current_user?(user)
    user == current_user
  end

  def logged_in?
    !current_user.nil?
  end

  def logout
    session.delete(:user_id)
  end
end
