# coding: utf-8
require 'active_support/core_ext'
require 'counterparty'
require 'json'

class ProjectsController < ApplicationController
  after_filter :verify_authorized, except: %i[index video video_embed embed embed_panel]
  inherit_resources
  has_scope :pg_search, :by_category_id, :near_of
  has_scope :recent, :expiring, :successful, :recommended, :not_expired, type: :boolean

  respond_to :html
  respond_to :json, only: [:index, :show, :update]


  def index

    index! do |format|
      format.html do
        if request.xhr?

          @projects = apply_scopes(Project).visible.order_for_search.includes(:project_total, :user, :category).page(params[:page]).per(6)
          @coins = Coin.find_all_by_project_id(@projects.id)
          return render partial: 'project', collection: @projects, layout: false
        else
          @title = t("site.title")
          if current_user && current_user.recommended_projects.present?
            @recommends = current_user.recommended_projects.limit(3)
          else
            @recommends = ProjectsForHome.recommends
          end

          if current_user #exists
            uid = current_user.id
            @coin_lists = Usercoin.select(:coin_id, :user_id, "sum(amount) as amount", "sum(redeemed_amount) as redeemed_amount").where(user_id: uid).group(:coin_id, :user_id).order("amount")
            @coin_lists = @coin_lists.collect { |c| {name: c.coin.name, description: c.coin.description, amount: c.amount, redeemed_amount: c.redeemed_amount} }
          end

          # TODO Show Projects

          @projects_near = Project.with_state('online').near_of(current_user.address_state).order("random()").limit(3) if current_user
          @expiring = Project.with_state('online')
          project_ids = @expiring.map { |p| p.id }
          if (current_user)
            @coins = Usercoin.where(user_id: current_user.id)
            params[:coins] = @coins
          end

          @recent = ProjectsForHome.recents

        end
      end
    end
  end

  def new
    @project = Project.new user: current_user
    authorize @project
    @title = t('projects.new.title')
    @project.rewards.build
  end

  def create

    # puts '*****************'
    # puts params

    # Create a new project based on parameters passed in
    # There's a hack here to work around the parameter passing problem for Koin Powers
    project_params = params[:project].select {|x| !x.include? "koin_powers"}

    # Extract Koin Powers from whatever being sent into as params
    powers = params['project'].select {|p| p.start_with? "koin_powers"}

    # Extract Koin Features from whatever being sent into as params
    features = params.select {|f| f.start_with? "koin_features"}

    puts powers
    puts features

    @project = Project.new project_params.merge(
      {
        user: current_user,
        uploaded_image: "http://localhost:3000/assets/projects/placeholder.png",
        name: params[:project][:koinname], 
        headline: params[:project][:headline], 
        permalink: params[:project][:koinname]+rand(10000).to_i.to_s,
        total_amount: params[:project][:goal],
        total_issued: Project::DEFAULT_COINS,
        amount_mined: 0,
        sold: 0,
        redeemed: 0,
        price: params[:project][:goal].to_f/Project::DEFAULT_COINS,
        koin_powers: powers.to_json,
        koin_features: features.to_json
        })
    # @project = Project.new project_params.merge(user: current_user).merge({name: params[:project][:koinname], headline: params[:project][:headline], permalink: params[:project][:koinname] })
    authorize @project
    @project.save


    # Create a corresponding Koin. In our world, a coin is really == project, we're doing both only because of the
    # legacy project concept in catarse, and to save some work

    

    coin_params = {
        user_id: current_user.id,
        project_id: @project.id,
        name:  params[:project][:koinname].to_s,
        koinpower: params[:project][:koinpower],
        total_amount: params[:project][:goal],
        total_issued: Project::DEFAULT_COINS,
        sold: 0,
        redeemed: 0,
        price: params[:project][:goal].to_f/Project::DEFAULT_COINS,
        description: params[:project][:headline]
    }

    coin = Coin.create(coin_params)



    # Create corresponding powers and features for the coin
    powers = params['project'].select {|p| p.start_with? "koin_powers"}
    powers.each do |p|
      name = p[1].split("@")[0]  
      if (p[1].split("@").size>0)
        cost = p[1].split("@")[1]
      end
      hh =  {coin_id: coin.id, name: name, description: name, cost:cost}
      puts hh
      p = KoinPower.new ({coin_id: coin.id, name: name, description: name, cost:cost})
      puts p
      puts p.errors.messages
      p.save
    end

    features = params.select {|f| f.start_with? "koin_features"}
    features.each do |f|
      f= f[1]
      name = f.split("@")[0]
      if (f.split("@").size>1)
        req = f.split("@")[1]
      else
        req = 0
      end
      f = KoinFeature.new ({coin_id: coin.id, name: name, description: name, requirement:req})
      hh = {coin_id: coin.id, name: name, description: name, requirement:req}
      puts hh
      puts f.errors.messages
      puts f.valid?
      f.save
    end

    # Create a default 25% Koin reward pool (for twitter) for the Coin
    reward = KoinReward.create(coin_id: coin.id, trigger: "twitter", amount: coin.total_issued / 1000, cap: coin.total_issued / 4)




    p = create! { project_by_slug_path(@project.permalink) }

    ## Auto approve the project. For Demo purpose.

    @project.send_to_analysis
    @project.approve

    # Synchronize it to counterpartyd
    # cp = Counterparty.new
    # if (!cp.create_asset("KO" +coin.name.upcase, coin.description, coin.total_issued.to_i))
    #
    # end
  end

  def destroy
    authorize resource
    destroy!
  end

  def send_to_analysis
    resource.send_to_analysis
    authorize @project
    flash[:notice] = t('projects.send_to_analysis')
    redirect_to project_by_slug_path(@project.permalink)
  end

  def update
    authorize resource
    update!(notice: t('projects.update.success')) { project_by_slug_path(@project.permalink, anchor: 'edit') }
  end

  def show
    @title = resource.name
    authorize @project
    fb_admins_add(resource.user.facebook_id) if resource.user.facebook_id
    @updates_count = resource.updates.count
    @update = resource.updates.where(id: params[:update_id]).first if params[:update_id].present?
  end

  def video
    project = Project.new(video_url: params[:url])
    render json: project.video.to_json
  rescue VideoInfo::UrlError
    render json: nil
  end

  %w(embed video_embed).each do |method_name|
    define_method method_name do
      @title = resource.name
      render layout: 'embed'
    end
  end

  def embed_panel
    @title = resource.name
    render layout: false
  end

  protected
  def permitted_params
    params.permit(policy(resource).permitted_attributes)
  end

  def resource
    @project ||= (params[:permalink].present? ? Project.by_permalink(params[:permalink]).first! : Project.find(params[:id]))
  end
end
