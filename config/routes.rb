Rails.application.routes.draw do
  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new
  mount BrowseEverything::Engine => '/browse'
  mount Bulkrax::Engine, at: '/'

  mount HealthMonitor::Engine, at: '/'
  mount Hyrax::IiifAv::Engine, at: '/'
  mount Riiif::Engine => 'images', as: :riiif if Hyrax.config.iiif_image_server?
  mount Blacklight::Engine => '/'

  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
    concerns :range_searchable
  end

  devise_for :users
  mount Qa::Engine => '/authorities'
  mount Hyrax::Engine, at: '/'
  resources :welcome, only: 'index'
  root 'hyrax/homepage#index'
  curation_concerns_basic_routes
  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  get '/institutions' => 'hyrax/pages#show', key: 'institutions'

  get '/collections', to: 'catalog#collections_index', as: 'collections'

  authenticate :user, lambda { |u| u.admin_area? } do
    mount DelayedJobWeb, at: "/delayed_job"
  end

  get 'participate' => 'hyrax/pages#show', key: 'participate'
  get 'search_tips' => 'hyrax/pages#show', key: 'search_tips'

  # Stop throwing 404s on missing map files. This route should be LAST
  get '/*path/*file.map', to: proc { [200, {}, ['']] }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
