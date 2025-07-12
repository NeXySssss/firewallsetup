#!/bin/bash

echo "Настройка UFW с ограничением портов 80/443 и пользовательским SSH-портом"

validate_port() {
    local port=$1
    if [[ "$port" =~ ^[0-9]+$ ]] && [ "$port" -ge 1 ] && [ "$port" -le 65535 ]; then
        return 0
    else
        return 1
    fi
}

SSH_PORT=""
while true; do
    read -p "Введите номер SSH-порта (от 1 до 65535): " SSH_PORT
    if validate_port "$SSH_PORT"; then
        echo "Выбранный SSH-порт: $SSH_PORT"
        break
    else
        echo "Неверный порт. Введите число от 1 до 65535."
    fi
done

CF_IPS="/etc/ufw/cloudflare_ips.txt"
mkdir -p /etc/ufw/

apt update && apt install -y ufw curl

ufw --force reset

ufw status numbered 2>/dev/null | grep -E '80|443|'$SSH_PORT | awk '{print $1}' | sort -nr | xargs -r -I {} ufw delete {}

echo "🌐 Получаем IP-адреса Cloudflare..."
curl -s https://www.cloudflare.com/ips-v4  > "$CF_IPS"
curl -s https://www.cloudflare.com/ips-v6  >> "$CF_IPS"

echo "🔒 Настраиваем доступ к портам 80/443 только с IP Cloudflare..."
while read ip; do
    ufw allow from "$ip" to any port 80 proto tcp >/dev/null
    ufw allow from "$ip" to any port 443 proto tcp >/dev/null
done < "$CF_IPS"

echo "🔓 Разрешаем подключение по SSH через порт $SSH_PORT"
ufw allow "$SSH_PORT"/tcp

ufw default deny incoming
ufw default allow outgoing

ufw --force enable

CRON_JOB="0 0 * * 0 root curl -s https://gist.githubusercontent.com/astr0vsky/9c2d7a2b3f8e4d7c0a1d2e3f6d7c4b5a/raw/cloudflare-ufw-interactive.sh  | bash -s -- < /dev/null > /var/log/cloudflare-ufw-update.log 2>&1"
(crontab -l 2>/dev/null | grep -v "cloudflare-ufw" ; echo "$CRON_JOB") | crontab -

echo ""
echo "Настройка завершена."
echo "Проверь статус фаервола: sudo ufw status verbose"
echo "Автоматическое обновление IP Cloudflare добавлено по воскресеньям в 00:00"