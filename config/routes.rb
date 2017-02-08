Rails.application.routes.draw do
  post 'upload-csv', to: 'logs#uploadCsv'
  get 'upload-csv', to: 'logs#setCsv'

  post 'query-logs', to: 'logs#retrieveLogs'
  get 'query-logs', to: 'logs#queryLogs'

  root 'logs#index'
end
