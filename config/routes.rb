Rails.application.routes.draw do
  namespace :api, path: "", defaults: { format: :json } do
    namespace :v1 do
      post "sign_up" => "registrations#create"
    end
  end
end
