from fastapi import APIRouter

from ..reference import CATEGORIES, DISTRICTS

router = APIRouter(prefix="/reference", tags=["reference"])


@router.get("/categories")
async def categories() -> list[dict[str, str]]:
    """Kategoriyalar. Ilova ishga tushganda bir marta oladi."""
    return CATEGORIES


@router.get("/districts")
async def districts() -> list[str]:
    """Farg'ona viloyatining shahar va tumanlari."""
    return DISTRICTS
