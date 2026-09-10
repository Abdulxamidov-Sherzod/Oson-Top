from fastapi import APIRouter, File, HTTPException, UploadFile, status

from ..deps import CurrentUser, Session
from ..models import ListingPhoto
from ..schemas.listing import PhotoOut
from ..services.storage import ImageTooLarge, NotAnImage, photo_url, save_photo

router = APIRouter(prefix="/photos", tags=["photos"])


@router.post("", response_model=PhotoOut, status_code=status.HTTP_201_CREATED)
async def upload(
    session: Session,
    user: CurrentUser,
    file: UploadFile = File(...),
) -> PhotoOut:
    """Rasmni oldindan yuklaydi. E'lon yaratilganda `photo_ids` ga
    shu id'lar beriladi — shunda forma to'ldirilayotganda rasm allaqachon
    serverga chiqib bo'ladi."""
    raw = await file.read()
    try:
        name, width, height = await save_photo(raw)
    except ImageTooLarge as exc:
        raise HTTPException(status.HTTP_413_REQUEST_ENTITY_TOO_LARGE, str(exc)) from exc
    except NotAnImage as exc:
        raise HTTPException(status.HTTP_422_UNPROCESSABLE_ENTITY, str(exc)) from exc

    photo = ListingPhoto(filename=name, width=width, height=height)
    session.add(photo)
    await session.commit()
    await session.refresh(photo)

    return PhotoOut(
        id=photo.id,
        url=photo_url(name),
        thumb_url=photo_url(name, thumb=True),
        width=width,
        height=height,
    )
