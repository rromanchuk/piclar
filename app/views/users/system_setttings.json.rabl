node :vk_scopes do
  CONFIG[:vk_scopes]
end

node :vk_client_id do
  CONFIG[:vk_app_id]
end

node :vk_url do
  "http://oauth.vk.com/authorize?client_id=#{CONFIG[:vk_app_id]}&scope=#{CONFIG[:vk_scopes]}&redirect_uri=http://oauth.vk.com/blank.html&display=touch&response_type=token" 
end