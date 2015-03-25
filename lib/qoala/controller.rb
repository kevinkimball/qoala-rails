module Qoala
  class BaseController < ActionController::Base

    before_filter :authenticate_request, :setup_model

    def index
      @fields = ActiveSupport::JSON.decode(params["fields"])
      @query  = params["query"]

      search  = ""
      args    = {}
      @fields.each_with_index do |field, i|
        search << "#{field} LIKE :#{field}"
        search << " OR " if i < @fields.size - 1
        args[field.to_sym] = "%#{@query}%"
      end

      result = @model.where(search, args).limit(10).to_json

      encryptor = ActiveSupport::MessageEncryptor.new(Qoala.settings.api_secret)
      encrypted_data = encryptor.encrypt_and_sign(result)

      render json: { records: encrypted_data }, status: 200
    end

    def show
      @record = @model.find(params["id"])

      if @record
        result = @record.to_json

        encryptor = ActiveSupport::MessageEncryptor.new(Qoala.settings.api_secret)
        encrypted_data = encryptor.encrypt_and_sign(result)

        render json: { record: encrypted_data }.to_json, status: 200
      else
        render nothing: true, status: 400
      end
    end

    def update
      @record = @model.find(params["id"])

      encryptor = ActiveSupport::MessageEncryptor.new(Qoala.settings.api_secret)
      params[:record] = encryptor.decrypt_and_verify(params[:record])

      params[:record].select!{|x| @model.attribute_names.index(x.to_s)}
      attributes = params.require(:record).permit!

      if @record.update(attributes)
        result = @record.to_json
        encrypted_data = encryptor.encrypt_and_sign(result)
        render json: { record: encrypted_data }.to_json, status: 200
      else
        render nothing: true, status: 400
      end
    end

    def destroy
      @record = @model.find(params["id"])

      encryptor = ActiveSupport::MessageEncryptor.new(Qoala.settings.api_secret)

      if @record.destroy
        result = @record.to_json
        encrypted_data = encryptor.encrypt_and_sign(result)
        render json: { record: encrypted_data }.to_json, status: 200
      else
        render nothing: true, status: 400
      end
    end

    private

      def authenticate_request
        unless request.headers["X-API-Key"] == Qoala.settings.api_key
          render nothing: true, status: 401
        end
      end

      def setup_model
        @model = params["model"].singularize.camelize.constantize
      end

  end
end
