from pydantic import BaseModel


class ModerationCounts(BaseModel):
    """Panel bo'limlari ustidagi sonlar."""

    moderation: int
    active: int
    rejected: int
