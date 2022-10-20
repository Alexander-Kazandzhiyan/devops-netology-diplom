# Для авторизации в сервисе CloudFlare указываем токен
provider "cloudflare" {
  api_token = "t44iHmKOjkxjsRvyyLzw27jCQb1WMT2DSr6IUgkI"
}


# Ищем нашу доменную зону.
data "cloudflare_zone" "domain-zone" {
  name = local.domain_name
}

# Добавляем записи для всех L3 доменных имён проекта, как псевдонимы A-записи домена L2 
resource "cloudflare_record" "diplom_domain-l3-record-www" {
  zone_id = data.cloudflare_zone.domain-zone.id
  name    = "www"
  value   = local.domain_name
  type    = "CNAME"
  ttl     = 60
}

resource "cloudflare_record" "diplom_domain-l3-record-gitlab" {
  zone_id = data.cloudflare_zone.domain-zone.id
  name    = "gitlab"
  value   = local.domain_name
  type    = "CNAME"
  ttl     = 60
}

resource "cloudflare_record" "diplom_domain-l3-record-alertmanager" {
  zone_id = data.cloudflare_zone.domain-zone.id
  name    = "alertmanager"
  value   = local.domain_name
  type    = "CNAME"
  ttl     = 60
}

resource "cloudflare_record" "diplom_domain-l3-record-grafana" {
  zone_id = data.cloudflare_zone.domain-zone.id
  name    = "grafana"
  value   = local.domain_name
  type    = "CNAME"
  ttl     = 60
}

resource "cloudflare_record" "diplom_domain-l3-record-prometheus" {
  zone_id = data.cloudflare_zone.domain-zone.id
  name    = "prometheus"
  value   = local.domain_name
  type    = "CNAME"
  ttl     = 60
}


# Создаём запись типа А с именем домена 2-го уровня. На неё будут ссылаться все дoмены 3 уровня, уже созданные в зоне
resource "cloudflare_record" "diplom_domain-l2-record" {
  zone_id = data.cloudflare_zone.domain-zone.id
  name    = "@"
  value   = aws_instance.diplom-vm-rproxy.public_ip
  type    = "A"
  ttl     = 60
  allow_overwrite  = true
}



