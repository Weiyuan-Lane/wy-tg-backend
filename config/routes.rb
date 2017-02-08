Rails.application.routes.draw do
  post 'upload-csv', to: 'logs#uploadCsv'
  get 'upload-csv', to: 'logs#index'

  post 'query-logs', to: 'logs#queryOrderLogs'
  get 'query-logs', to: 'logs#index'

  root 'logs#index'
end
