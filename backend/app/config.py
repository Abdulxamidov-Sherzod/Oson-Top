from functools import lru_cache
from pathlib import Path

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Sozlamalar .env faylidan o'qiladi. Namuna: .env.example"""

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    database_url: str = "postgresql+asyncpg://oson:oson@localhost:5432/oson_top"

    jwt_secret: str = "almashtiring-bu-faqat-test-uchun"
    access_token_minutes: int = 30
    refresh_token_days: int = 30

    # Telegram bot — kirish shu orqali. @BotFather dan olinadi.
    telegram_bot_token: str = ""
    telegram_bot_username: str = ""
    # Bo'sh bo'lsa long polling ishlatiladi (domen kerak emas).
    # Serverda webhook qo'ying: https://api.example.com/api/v1/auth/telegram/webhook
    telegram_webhook_url: str = ""
    telegram_webhook_secret: str = ""

    # Telegramsiz kirish — faqat ishlab chiqishda. Ishlab chiqarishda false!
    allow_dev_login: bool = False

    # Egalarining raqamlari — bu raqam bilan kirgan hisob har safar admin
    # bo'lib qoladi. Baza tozalansa ham huquq yo'qolmaydi, qo'lda UPDATE
    # qilish kerak emas. Vergul bilan: +998901112233,+998901112244
    # Yozilish shakli muhim emas — app/roles.py normallashtirib solishtiradi.
    admin_phones: str = ""

    # local | supabase
    storage_backend: str = "local"
    supabase_url: str = ""
    supabase_service_key: str = ""
    supabase_bucket: str = "listing-photos"

    # Push bildirishnoma — Firebase xizmat hisobi kalitining JSON'i.
    # Bo'sh bo'lsa push o'chiq, ilova esa avvalgidek ishlayveradi.
    fcm_service_account: str = ""

    media_dir: Path = Path("./media")
    media_url: str = "/media"
    max_photo_mb: int = 8

    # true bo'lsa e'lon moderatorsiz darhol chiqadi (faqat test uchun)
    auto_approve: bool = False

    @property
    def max_photo_bytes(self) -> int:
        return self.max_photo_mb * 1024 * 1024



@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
