from typing import Generic, TypeVar

from pydantic import BaseModel, Field

T = TypeVar("T")


class Page(BaseModel, Generic[T]):
    items: list[T]
    total: int
    limit: int
    offset: int

    @property
    def has_more(self) -> bool:
        return self.offset + len(self.items) < self.total


class Ok(BaseModel):
    ok: bool = True


class Message(BaseModel):
    message: str


class PageParams(BaseModel):
    limit: int = Field(20, ge=1, le=50)
    offset: int = Field(0, ge=0)
