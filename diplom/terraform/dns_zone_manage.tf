# Для авторизации в сервисе CloudFlare указываем токен
provider "cloudflare" {
  api_token = "t44iHmKOjkxjsRvyyLzw27jCQb1WMT2DSr6IUgkI"
}


# Ищем нашу доменную зону.
data "cloudflare_zone" "domain-zone" {
  name = local.domain_name
}


# Создаём запись типа А с именем домена 2-го уровня. На неё будут ссылаться все длмены 3 уровня, уже созданные в зоне
resource "cloudflare_record" "diplom_domain-l2-record" {
  zone_id = data.cloudflare_zone.domain-zone.id
  name    = "@"
  value   = aws_instance.diplom-vm-rproxy.public_ip
  type    = "A"
  ttl     = 60
  allow_overwrite  = true
}

# Add a record to the domain
#resource "cloudflare_record" "diplom_domain-l2-record" {
#  zone_id = data.cloudflare_zone.domain-zone.id
#  name    = "terraform"
#  value   = "192.168.0.11"
#  type    = "A"
#  ttl     = 60
#}



