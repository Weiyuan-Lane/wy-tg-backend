Rails.application.routes.draw do
  post 'upload-csv', to: 'logs#uploadCsv'

  root 'logs#index'
end
