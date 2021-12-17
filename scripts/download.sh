#!/bin/bash
set -e

if [ -z "$ONEC_USERNAME" ]
then
    echo "ONEC_USERNAME not set"
    exit 1
fi

if [ -z "$ONEC_PASSWORD" ]
then
    echo "ONEC_PASSWORD not set"
    exit 1
fi

if [ -z "$ONEC_VERSION" ]
then
    echo "ONEC_VERSION not set"
    exit 1
fi

SRC=$(curl -c /tmp/cookies.txt -s -L https://releases.1c.ru)
ACTION=$(echo "$SRC" | grep -oP '(?<=form method="post" id="loginForm" action=")[^"]+(?=")')
EXECUTION=$(echo "$SRC" | grep -oP '(?<=input type="hidden" name="execution" value=")[^"]+(?=")')

curl -s -L \
    -o /dev/null \
    -b /tmp/cookies.txt \
    -c /tmp/cookies.txt \
    --data-urlencode "inviteCode=" \
    --data-urlencode "execution=$EXECUTION" \
    --data-urlencode "_eventId=submit" \
    --data-urlencode "username=$ONEC_USERNAME" \
    --data-urlencode "password=$ONEC_PASSWORD" \
    https://login.1c.ru"$ACTION"

if ! grep -q "TGC" /tmp/cookies.txt
then
    echo "Auth failed"
    exit 1
fi

if [[ "$installer_type" == "edt" ]]; then

caption1="1C:Enterprise Development Tools для Linux 64 Bit"
caption2="Дистрибутив для оффлайн установки 1C:EDT для ОС Linux 64 бит"

EDTPATHLINK=$(curl -s -G \
-b /tmp/cookies.txt \
--data-urlencode "nick=DevelopmentTools10" \
--data-urlencode "ver=$EDT_VERSION" \
https://releases.1c.ru/version_files | grep -oP "(?<=a href=\")[^\"]+path=(.*)(?=\">(?:$caption1|$caption2)<)" | grep -oP '(?<=path=).*')

EDTLINK=$(curl -s -v -G \
    -b /tmp/cookies.txt \
    --data-urlencode "nick=DevelopmentTools10" \
    --data-urlencode "ver=$EDT_VERSION" \
    --data "path=$EDTPATHLINK" \
    https://releases.1c.ru/version_file | grep -oP '(?<=a href=")[^"]+(?=">Скачать дистрибутив<)')
else

THINCLIENTLINK=$(curl -s -G \
    -b /tmp/cookies.txt \
    --data-urlencode "nick=Platform83" \
    --data-urlencode "ver=$ONEC_VERSION" \
    --data-urlencode "path=Platform\\${ONEC_VERSION//./_}\\thin.client64_${ONEC_VERSION//./_}.tar.gz" \
    https://releases.1c.ru/version_file | grep -oP '(?<=a href=")[^"]+(?=">Скачать дистрибутив<)')

THINCLIENT32LINK=$(curl -s -G \
    -b /tmp/cookies.txt \
    --data-urlencode "nick=Platform83" \
    --data-urlencode "ver=$ONEC_VERSION" \
    --data-urlencode "path=Platform\\${ONEC_VERSION//./_}\\thin.client32_${ONEC_VERSION//./_}.tar.gz" \
    https://releases.1c.ru/version_file | grep -oP '(?<=a href=")[^"]+(?=">Скачать дистрибутив<)')

SERVERLINK=$(curl -s -G \
    -b /tmp/cookies.txt \
    --data-urlencode "nick=Platform83" \
    --data-urlencode "ver=$ONEC_VERSION" \
    --data-urlencode "path=Platform\\${ONEC_VERSION//./_}\\server64_${ONEC_VERSION//./_}.tar.gz" \
    https://releases.1c.ru/version_file | grep -oP '(?<=a href=")[^"]+(?=">Скачать дистрибутив<)')

SERVER32LINK=$(curl -s -G \
    -b /tmp/cookies.txt \
    --data-urlencode "nick=Platform83" \
    --data-urlencode "ver=$ONEC_VERSION" \
    --data-urlencode "path=Platform\\${ONEC_VERSION//./_}\\server32_${ONEC_VERSION//./_}.tar.gz" \
    https://releases.1c.ru/version_file | grep -oP '(?<=a href=")[^"]+(?=">Скачать дистрибутив<)')
fi

case "$installer_type" in
  edt)
      echo "edt"
      curl --fail -b /tmp/cookies.txt -o edt.tar.gz -L "$EDTLINK"
      ;;
  server)
      curl --fail -b /tmp/cookies.txt -o server.tar.gz -L "$SERVERLINK"
      ;;
  server32)
      curl --fail -b /tmp/cookies.txt -o server32.tar.gz -L "$SERVER32LINK"
      ;;
  client)
      curl --fail -b /tmp/cookies.txt -o server.tar.gz -L "$SERVERLINK"
      ;;
  client32)
      curl --fail -b /tmp/cookies.txt -o server32.tar.gz -L "$SERVER32LINK"
      ;;
  thin-client)
      curl --fail -b /tmp/cookies.txt -o thin-client.tar.gz -L "$THINCLIENTLINK"
      ;;
  thin-client32)
      curl --fail -b /tmp/cookies.txt -o thin-client32.tar.gz -L "$THINCLIENT32LINK"
esac

rm /tmp/cookies.txt
