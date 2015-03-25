Rails.application.routes.draw do
  namespace :qoala do
    post    "/:model"     => "base#index"
    post    "/:model/:id" => "base#show"
    patch   "/:model/:id" => "base#update"
    delete  "/:model/:id" => "base#destroy"
  end
end
