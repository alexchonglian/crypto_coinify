require 'counterparty'
##
## Contributions is the original concept in catarse class. In Koinify's world, UserCoin should be the correct controller and model
## to maange.
## However, We're currently piggybacking on this controller to achieve that to save time.
##
class Projects::ContributionsController < ApplicationController
  inherit_resources
  actions :index, :show, :new, :update, :review, :create, :credits_checkout, :success
  skip_before_filter :force_http
  skip_before_filter :verify_authenticity_token, only: [:moip]
  has_scope :available_to_count, type: :boolean
  has_scope :with_state
  has_scope :page, default: 1

  after_filter :verify_authorized, except: [:index]
  belongs_to :project
  before_filter :detect_old_browsers, only: [:new, :create]



  # Called upon payment success
  # 1. We'll mark the contribution coin issued, and create a new Usercoin record
  # 2. Push the new asset to Counterpartyd
  def success
    authorize resource
    # If the usercoin has been created, then create new user coin
    unless (@contribution.coin_status == 'issued' )
      puts "Let's give the user some coins"
      @myuser = current_user
      puts "Current user is:" + current_user.id.to_s
      @mycoin = Coin.where(project: parent).first

      # Create the new coin-user relationship in usercoin
      c = Usercoin.where(:user_id => @myuser.id, :coin_id => @mycoin.id).first
      if c == nil
            c = Usercoin.new(:user_id => @myuser.id, :coin_id => @mycoin.id, :amount => @contribution.amount)
      else
            c.amount += @contribution.amount
      end


      c.save
      @contribution.coin_status = 'issued'
      @contribution.save

      # Synchronize to counterparty and create a new asset
      # cp = Counterparty.new
      # cp.give_coin(@mycoin.name, @myuser.cp_address, @contribution.amount)

    end
  end
  def edit
    authorize resource


  end

  def update
    authorize resource
    resource.update_attributes(permitted_params[:contribution])
    resource.update_user_billing_info
    render json: {message: 'updated'}
  end

  def index
    render collection
  end

  def show
    authorize resource
    @title = t('projects.contributions.show.title')



  end



  #
  def new

    @contribution = Contribution.new(project: parent, user: current_user)
    authorize @contribution

    @title = t('projects.contributions.new.title', name: @project.name)
    empty_reward = Reward.new(minimum_value: 0, description: t('projects.contributions.new.no_reward'))
    @rewards = [empty_reward] + @project.rewards.remaining.order(:minimum_value)



    # Select
    if params[:reward_id] && (@selected_reward = @project.rewards.find params[:reward_id]) && !@selected_reward.sold_out?
      @contribution.reward = @selected_reward
      @contribution.value = "%0.0f" % @selected_reward.minimum_value

    end


  end

  def create
    @title = t('projects.contributions.create.title')
    price = Coin.where(project_id: params[:project_id]).first.price
    amount = params[:contribution][:value]
    puts params[:contribution]
    @contribution = Contribution.new(params[:contribution].merge(user: current_user, project: parent, amount: amount))

    @contribution.reward_id = nil if params[:contribution][:reward_id].to_i == 0


    puts "You're purchasing #{amount} coins, at a price of #{price} "

    authorize @contribution
    create! do |success,failure|
      failure.html do
        flash[:failure] = t('projects.contributions.review.error')
        return redirect_to new_project_contribution_path(@project)
      end
      success.html do
        resource.update_current_billing_info
        flash[:notice] = nil
        session[:thank_you_contribution_id] = @contribution.id
        return redirect_to edit_project_contribution_path(project_id: @project.id, id: @contribution.id)
      end
    end
    @thank_you_id = @project.id
  end

  def credits_checkout
    authorize resource
    if current_user.credits < @contribution.value
      flash[:failure] = t('projects.contributions.checkout.no_credits')
      return redirect_to new_project_contribution_path(@contribution.project)
    end

    unless @contribution.confirmed?
      @contribution.update_attributes({ payment_method: 'Credits' })
      @contribution.confirm!
    end
    flash[:success] = t('projects.contributions.checkout.success')
    redirect_to project_contribution_path(project_id: parent.id, id: resource.id)
  end

  protected
  def permitted_params
    params.permit(policy(resource).permitted_attributes)
  end

  def collection
    @contributions ||= apply_scopes(end_of_association_chain).available_to_display.order("confirmed_at DESC").per(10)
  end
end
