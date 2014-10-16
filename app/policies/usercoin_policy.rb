class UsercoinPolicy < ApplicationPolicy
  def redeem?
    done_by_owner_or_admin?
  end

  protected
  def done_by_owner_or_admin?
    record == user
  end
end

