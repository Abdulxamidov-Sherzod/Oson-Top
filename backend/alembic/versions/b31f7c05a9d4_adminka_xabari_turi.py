"""Bildirishnoma turiga adminka xabari qo'shildi

Revision ID: b31f7c05a9d4
Revises: 9c2ad4e71b30
"""

from collections.abc import Sequence

from alembic import op

revision: str = 'b31f7c05a9d4'
down_revision: str | None = '9c2ad4e71b30'
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    # PostgreSQL 12+ da bu tranzaksiya ichida ham ishlaydi — yangi qiymat
    # shu tranzaksiyada ishlatilmasa bo'ldi.
    op.execute("ALTER TYPE notification_kind ADD VALUE IF NOT EXISTS 'announcement'")


def downgrade() -> None:
    # PostgreSQL enum'dan qiymat olib tashlashni qo'llab-quvvatlamaydi
    pass
