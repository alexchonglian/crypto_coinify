# coding: utf-8

puts 'Seeding the database...'

[
  { pt: 'Arte', en: 'Art' },

  { pt: 'Comunidade', en: 'Community' },

  { pt: 'Design', en: 'Design' },
  { pt: 'Eventos', en: 'Events' },

  { pt: 'Cinema e Vídeo', en: 'Film & Video' },
  { pt: 'Jogos', en: 'Games' },

  { pt: 'Ciência e Tecnologia', en: 'Distributed Applications' },

  { pt: 'Esporte', en: 'Sport' },

  { pt: 'Negócios Sociais', en: 'Social Causes' },

].each do |name|
   category = Category.find_or_initialize_by(name_pt: name[:pt])
   category.update_attributes({
     name_en: name[:en]
   })
 end


BASE_WITH_PORT = "http://0.0.0.0:3000"

{
  company_name: 'Koinify',
#  company_logo: 'http://catarse.me/assets/catarse_bootstrap/logo_icon_catarse.png',
  company_logo: 'http://res.cloudinary.com/hrscywv4p/image/upload/c_limit,h_540,w_720/dyorluk3i5mtjygcrlbt.png',
  host: '0.0.0.0',
  base_url: "http://0.0.0.0",
  base_url_with_port: "http://0.0.0.0:3000",

  paypal_username: "coinifycorp_api1.gmail.com",
  paypal_password: "STQFUXJ44RHSZ7WX",
  paypal_signature: "Ao.SUhILNU2Xl8sj4oJuNNriRjgOAVA9RDfSY5iTTxWgfn43WVdXFOvQ",

  email_contact: 'contato@catarse.me',
  email_payments: 'financeiro@catarse.me',
  email_projects: 'projetos@catarse.me',
  email_system: 'system@catarse.me',
  email_no_reply: 'no-reply@catarse.me',
  facebook_url: "https://www.facebook.com/pages/Koinify/409031959239893",
  facebook_app_id: '',
  twitter_url: 'https://twitter.com/koinify',
  twitter_username: "koinify",
  mailchimp_url: "http://catarse.us5.list-manage.com/subscribe/post?u=ebfcd0d16dbb0001a0bea3639&amp;id=149c39709e",
  catarse_fee: '0.05',
  support_forum: BASE_WITH_PORT + '/help',
  base_domain: '0.0.0.0',
  uservoice_secret_gadget: 'change_this',
  uservoice_key: 'uservoice_key',
  faq_url: BASE_WITH_PORT + '/help',
  feedback_url: BASE_WITH_PORT + '/feedback',
  terms_url: BASE_WITH_PORT + '/terms',
  privacy_url: BASE_WITH_PORT + '/privacy',
  about_channel_url: 'http://blog.catarse.me/conheca-os-canais-do-catarse/',
  instagram_url: 'http://instagram.com/catarse_',
  blog_url: BASE_WITH_PORT + '/blog',
  github_url: 'http://github.com/catarse',
  contato_url: BASE_WITH_PORT + '/help'
}.each do |name, value|
# Caution: The following original way won't update the values!!
#   conf = CatarseSettings.find_or_initialize_by(name: name)
#   conf.update_attributes({
#     value: value
#    })
#   }) if conf.new_record?
  CatarseSettings[name]=value
end


Channel.find_or_create_by!(name: "Channel name") do |c|
  c.permalink = "sample-permalink"
  c.description = "Lorem Ipsum"
end


OauthProvider.find_or_create_by!(name: 'facebook') do |o|
  o.key = 'your_facebook_app_key'
  o.secret = 'your_facebook_app_secret'
  o.path = 'facebook'
end

OauthProvider.find_or_create_by!(name: 'twitter') do |o|
  o.key = 'JztZCU505BbRBIV2iDO3Yfhap'
  o.secret = 'WZDp1dK0cTa4Np3k7uchUdMbQhaJ6yvyECRJTPb6DFIyDTxJL9'
  o.path = 'twitter'
end

puts
puts '============================================='
puts ' Showing all Authentication Providers'
puts '---------------------------------------------'

OauthProvider.all.each do |conf|
  a = conf.attributes
  puts "  name #{a['name']}"
  puts "     key: #{a['key']}"
  puts "     secret: #{a['secret']}"
  puts "     path: #{a['path']}"
  puts
end


puts
puts '============================================='
puts ' Showing all entries in Configuration Table...'
puts '---------------------------------------------'

CatarseSettings.all.each do |conf|
  a = conf.attributes
  puts "  #{a['name']}: #{a['value']}"
end

puts '---------------------------------------------'
puts 'Done!'
