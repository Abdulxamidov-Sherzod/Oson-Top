from pydantic import BaseModel, Field


class LoginStart(BaseModel):
    """Ilova shu havolani ochadi va `token` bilan holatni so'rab turadi."""

    token: str
    deep_link: str
    expires_in: int


class LoginStatus(BaseModel):
    # pending — hali botda tugatilmagan; ready — tokenlar tayyor
    status: str
    access_token: str | None = None
    refresh_token: str | None = None


class Tokens(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"


class RefreshIn(BaseModel):
    refresh_token: str


class DevLoginIn(BaseModel):
    """Faqat ALLOW_DEV_LOGIN=true bo'lganda ishlaydi."""

    phone: str = Field(..., examples=["+998901234567"])
