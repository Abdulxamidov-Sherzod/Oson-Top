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
