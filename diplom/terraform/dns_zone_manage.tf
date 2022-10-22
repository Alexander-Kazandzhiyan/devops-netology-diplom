######## Тут мы используя провайдер cloudflare для Terraform заходим в настройки, заранее созданной "пустой" доменной зоны для нашего домена и добавляем записи ###########


# Для авторизации в сервисе CloudFlare указываем токен
provider "cloudflare" {
  api_token = local.cloudflare_api_token
}


# Ищем нашу доменную зону.
data "cloudflare_zone" "domain-zone" {
  name = local.domain_name
}

# Создаём запись типа А с именем домена 2-го уровня c полученным от AWS публичным IP-адресом. На неё будут ссылаться все дoмены 3 уровня, уже созданные в зоне
resource "cloudflare_record" "diplom_domain-l2-record" {
  zone_id = data.cloudflare_zone.domain-zone.id
  name    = "@"
  value   = aws_instance.diplom-vm-rproxy.public_ip
  type    = "A"
  ttl     = 60
  allow_overwrite  = true
}

# Добавляем записи для всех L3 доменных имён проекта, как псевдонимы A-записи домена L2 

resource "cloudflare_record" "diplom_domain-l3-record-www" {
  zone_id = data.cloudflare_zone.domain-zone.id
  name    = "www"
  value   = local.domain_name
  type    = "CNAME"
  ttl     = 60
  allow_overwrite  = true
}

resource "cloudflare_record" "diplom_domain-l3-record-gitlab" {
  zone_id = data.cloudflare_zone.domain-zone.id
  name    = "gitlab"
  value   = local.domain_name
  type    = "CNAME"
  ttl     = 60
  allow_overwrite  = true
}

resource "cloudflare_record" "diplom_domain-l3-record-alertmanager" {
  zone_id = data.cloudflare_zone.domain-zone.id
  name    = "alertmanager"
  value   = local.domain_name
  type    = "CNAME"
  ttl     = 60
  allow_overwrite  = true
}

resource "cloudflare_record" "diplom_domain-l3-record-grafana" {
  zone_id = data.cloudflare_zone.domain-zone.id
  name    = "grafana"
  value   = local.domain_name
  type    = "CNAME"
  ttl     = 60
  allow_overwrite  = true
}

resource "cloudflare_record" "diplom_domain-l3-record-prometheus" {
  zone_id = data.cloudflare_zone.domain-zone.id
  name    = "prometheus"
  value   = local.domain_name
  type    = "CNAME"
  ttl     = 60
  allow_overwrite  = true
}
