"""Push olib tashlandi — qurilma tokenlari jadvali o'chiriladi

Revision ID: c7e0f2a41d85
Revises: b31f7c05a9d4

Bildirishnoma turidagi 'announcement' qiymati qoladi: PostgreSQL enum'dan
qiymat olib tashlashni qo'llab-quvvatlamaydi. Bo'sh qiymat zarar qilmaydi,
lekin shu turdagi yozuvlar qolsa ilova ularni o'qiy olmaydi — shuning uchun
ular o'chiriladi.
"""

from collections.abc import Sequence

from alembic import op

revision: str = 'c7e0f2a41d85'
down_revision: str | None = 'b31f7c05a9d4'
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.execute("DELETE FROM notifications WHERE kind = 'announcement'")
    op.drop_index(op.f('ix_device_tokens_token'), table_name='device_tokens')
    op.drop_index(op.f('ix_device_tokens_user_id'), table_name='device_tokens')
    op.drop_table('device_tokens')


def downgrade() -> None:
    # Orqaga qaytarish ma'nosiz — jadval push bilan birga qaytadi
    pass
