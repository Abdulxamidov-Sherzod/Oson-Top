from datetime import datetime

from pydantic import BaseModel

from ..models.enums import NotificationKind


class NotificationOut(BaseModel):
    id: int
    kind: NotificationKind
    title: str
    body: str
    listing_id: int | None
    unread: bool
    created_at: datetime

    model_config = {"from_attributes": True}


class UnreadCount(BaseModel):
    unread: int
