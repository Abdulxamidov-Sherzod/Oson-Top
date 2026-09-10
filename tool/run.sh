#!/usr/bin/env bash
# Ilovani ishga tushirish.
#
# Yandex MapKit'ning "full" varianti kerak — qidiruv va geokodlash faqat
# unda bor. Variant muhit o'zgaruvchisi orqali tanlanadi, shuning uchun
# flutter'ni to'g'ridan-to'g'ri emas, shu skript orqali chaqiring:
#
#     ./tool/run.sh run
#     ./tool/run.sh build ios --simulator
set -euo pipefail

export YANDEX_MAPKIT_VARIANT=full
export LANG=en_US.UTF-8
export PATH="/opt/homebrew/bin:$PATH"

exec flutter "$@"
