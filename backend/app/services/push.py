"""Push bildirishnoma — Firebase Cloud Messaging (HTTP v1).

Google'ning SDK'si o'rniga to'g'ridan-to'g'ri API: xizmat hisobi kaliti bilan
JWT imzolanadi, u OAuth2 tokeniga almashtiriladi va shu token bilan xabar
yuboriladi. Ikkala kutubxona (pyjwt, httpx) allaqachon loyihada bor.

Sozlanmagan bo'lsa hech narsa yubormaydi va xato ham chiqarmaydi — ilova
Firebase'siz ham ishlashi kerak.
"""

import json
import logging
import time

import httpx
import jwt

from ..config import settings

log = logging.getLogger("oson.push")

_TOKEN_URL = "https://oauth2.googleapis.com/token"
_SCOPE = "https://www.googleapis.com/auth/firebase.messaging"

# (token, tugash vaqti) — har yuborishda qayta so'ramaymiz
_cached: tuple[str, float] | None = None


def _account() -> dict | None:
    raw = settings.fcm_service_account.strip()
    if not raw:
        return None
    try:
        return json.loads(raw)
    except json.JSONDecodeError:
        log.error("FCM_SERVICE_ACCOUNT JSON emas — push o'chirilgan")
        return None


def configured() -> bool:
    return _account() is not None


async def _access_token() -> str | None:
    global _cached
    if _cached is not None and _cached[1] > time.time() + 60:
        return _cached[0]

    account = _account()
    if account is None:
        return None

    now = int(time.time())
    assertion = jwt.encode(
        {
            "iss": account["client_email"],
            "scope": _SCOPE,
            "aud": _TOKEN_URL,
            "iat": now,
            "exp": now + 3600,
        },
        account["private_key"],
        algorithm="RS256",
    )

    async with httpx.AsyncClient(timeout=15) as client:
        resp = await client.post(
            _TOKEN_URL,
            data={
                "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
                "assertion": assertion,
            },
        )
    if resp.status_code != 200:
        log.error("FCM tokeni olinmadi: %s %s", resp.status_code, resp.text[:200])
        return None

    body = resp.json()
    _cached = (body["access_token"], time.time() + body.get("expires_in", 3600))
    return _cached[0]


async def send(
    tokens: list[str],
    *,
    title: str,
    body: str,
    data: dict[str, str] | None = None,
) -> list[str]:
    """Xabarni yuboradi va yaroqsiz tokenlar ro'yxatini qaytaradi.

    FCM v1 bitta so'rovda bitta qurilmaga yuboradi, shuning uchun tokenlar
    ketma-ket aylanib chiqiladi. Bizdagi hajmda bu yetarli.
    """
    if not tokens:
        return []

    account = _account()
    access = await _access_token()
    if account is None or access is None:
        log.info("Push sozlanmagan — %d ta qurilmaga yuborilmadi", len(tokens))
        return []

    url = (
        f"https://fcm.googleapis.com/v1/projects/{account['project_id']}"
        "/messages:send"
    )
    headers = {"Authorization": f"Bearer {access}"}
    dead: list[str] = []

    async with httpx.AsyncClient(timeout=20) as client:
        for token in tokens:
            payload = {
                "message": {
                    "token": token,
                    "notification": {"title": title, "body": body},
                    "data": {k: str(v) for k, v in (data or {}).items()},
                    "android": {"priority": "high"},
                    "apns": {
                        "payload": {"aps": {"sound": "default", "badge": 1}}
                    },
                }
            }
            try:
                resp = await client.post(url, headers=headers, json=payload)
            except httpx.HTTPError as exc:
                log.warning("Push yuborilmadi: %s", exc)
                continue

            if resp.status_code == 200:
                continue
            # Qurilmadan ilova o'chirilgan yoki token eskirgan
            if resp.status_code in (400, 403, 404):
                log.info("Yaroqsiz token o'chiriladi: %s", resp.status_code)
                dead.append(token)
            else:
                log.warning("Push xatosi %s: %s", resp.status_code, resp.text[:200])

    return dead
