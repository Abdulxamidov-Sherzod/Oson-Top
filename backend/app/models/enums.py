import enum


class ListingStatus(enum.StrEnum):
    """E'lonning hayot yo'li: moderatsiya → aktiv → sotilgan/muddati tugagan."""

    moderation = "moderation"
    active = "active"
    rejected = "rejected"
    expired = "expired"
    sold = "sold"


class ListingCondition(enum.StrEnum):
    fresh = "fresh"
    used = "used"
    none = "none"


class UserRole(enum.StrEnum):
    user = "user"
    moderator = "moderator"
    admin = "admin"


class NotificationKind(enum.StrEnum):
    matched_search = "matched_search"
    price_drop = "price_drop"
    approved = "approved"
    rejected = "rejected"
    call = "call"
    expiring = "expiring"
    # Adminkadan yuborilgan xabar
    announcement = "announcement"
