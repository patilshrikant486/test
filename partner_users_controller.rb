class V1::PartnerUsersController < V1::BaseController

  before_filter(only: :create) { |c| c.check_params(:partner_account_id, :partner_user) }
	before_filter(only: :update) { |c| c.check_params(:id, :partner_account_id, :partner_user) }
  before_filter(only: :destroy)    { |c| c.check_params(:id, :partner_account_id) }
  before_filter(only: :send_email) { |c| c.check_params(:id, :partner_account_id, :keyword) }
  before_filter :require_partner_account
  before_filter :require_user, except: :create

  # POST /v1/partner_users/
  # required parametets - partner_account_id, partner_user
  def create
    params[:partner_user][:crypted_password] = convert_to_md5(params[:partner_user][:crypted_password]) unless params[:partner_user][:crypted_password].blank?
    @user = @partner_account.users.new(partner_user_params)
    raise CustomerlobbyErrors::UnprocessableEntityError.new @user.errors.full_messages unless @user.save
  end

  # PUT /v1/partner_users/:id
  # required parametets - id, partner_account_id, partner_user
  def update
    raise CustomerlobbyErrors::NotFoundError.new 'A partner user with the provided id could not be found' if @user.blank?
    params[:partner_user][:crypted_password] = convert_to_md5(params[:partner_user][:crypted_password]) unless params[:partner_user][:crypted_password].blank?
    raise CustomerlobbyErrors::UnprocessableEntityError.new @user.errors.full_messages unless
      @user.update_attributes(partner_user_params)
  end

  # GET /v1/partner_users/:id/send_email
  # required parametets - id, keyword, partner_account_id
  def send_email
    raise CustomerlobbyErrors::NotFoundError.new 'A partner user with the provided id could not be found' if @user.blank?
    @user.send_email(params)
  end


  # DELETE /v1/partner_users/:id
  # required parametets - id, partner_account_id
  def destroy
    @user = @partner_account.users.find(params[:id])
    raise CustomerlobbyErrors::NotFoundError.new 'A partner user with the provided id could not be found' if @user.blank?
    @user.destroy
  end

  protected

  def require_partner_account
    @partner_account = PartnerAccount.find(params[:partner_account_id])
  end

  def require_user
  	@user = PartnerUser.find(params[:id])
  end

  private

  def partner_user_params
    params.require(:partner_user).permit(:partner_account_id, :first_name, :last_name, :email, :crypted_password,
                                         :is_active, :is_owner, :password, :password_confirmation)
  end
end
