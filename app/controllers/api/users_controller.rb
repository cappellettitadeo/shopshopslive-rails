class Api::UsersController < ApiController
  def create
    if params[:user][:phone].present?
      user = User.where(phone: params[:user][:phone]).first_or_create
      user.update_attributes(user_params)
      if params[:user][:addresses].present?
        adds = params[:user][:addresses]
        adds.each do |add|
          hash = {
            first_name: add[:first_name],
            last_name: add[:last_name],
            full_name: add[:full_name].present? ? add[:full_name] : "#{add[:last_name]} #{add[:first_name]}",
            phone: (add[:phone].present? ? add[:phone] : user.phone),
            address1: add[:address1],
            city: add[:city],
            province: add[:province],
            country: (add[:country].present? ? add[:country] : 'CN'),
          }
          begin
            user.shipping_addresses.create!(hash)
          rescue => e
            render json: { ec: 400, em: e.message }, status: :bad_request and return
          end
        end
      end
      hash = UserSerializer.new(user).serializable_hash
      render json: hash, status: :ok
    else
      render json: { ec: 400, em: "请输入手机号" }, status: :bad_request
    end
  end

  def update
		user = User.find params[:id]
    if user
      user.update_attributes(user_params)
      hash = UserSerializer.new(user).serializable_hash
      render json: hash, status: :ok
    else
      render json: { ec: 404, em: "无法找到该用户" }, status: :not_found
    end
  end

  def show
		user = User.find params[:id]
    if user
      hash = UserSerializer.new(user).serializable_hash
      render json: hash, status: :ok
    else
      render json: { ec: 404, em: "无法找到该用户" }, status: :not_found
    end
  end

  private
  def user_params
    params.require(:user).permit(:full_name, :first_name, :last_name, :gender, :email, :phone, :addresses)
  end
end
