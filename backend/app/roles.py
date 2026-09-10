"""Rol berish qoidalari."""

from .config import settings
from .models import User, UserRole
from .security import normalize_phone


def owner_phones() -> frozenset[str]:
    """ADMIN_PHONES ni bazadagi shaklga keltiradi.

    .env ga '+998 90 111 22 33' ham, '901112233' ham yozilishi mumkin —
    bazada esa raqam har doim '+998901112233'. Solishtirish ishlashi uchun
    ikkala tomonni ham bir shaklga keltiramiz.
    """
    return frozenset(
        normalized
        for raw in settings.admin_phones.split(",")
        if (normalized := normalize_phone(raw))
    )


def apply_owner_role(user: User) -> bool:
    """ADMIN_PHONES ro'yxatidagi raqam har doim admin bo'lib qoladi.

    Kirish paytida chaqiriladi. Shu tufayli egasi huquqini qo'lda bazaga
    kirib bermaydi — .env ga raqam yozilsa yetarli, va seed baza tozalab
    yuborsa ham huquq keyingi kirishda qaytadi.

    True qaytarsa — rol o'zgardi, commit kerak.
    """
    if not user.phone or user.phone not in owner_phones():
        return False
    if user.role == UserRole.admin:
        return False
    user.role = UserRole.admin
    return True
