"""Model → schema o'girish. Bir joyda tursin — bir necha endpoint ishlatadi."""

from ..models import Listing, User
from ..schemas.listing import ListingCard, ListingOut, PhotoOut, SpecOut
from ..schemas.user import SellerOut
from ..services.storage import photo_url


def to_card(listing: Listing, favorite_ids: set[int]) -> ListingCard:
    cover = listing.photos[0] if listing.photos else None
    return ListingCard(
        id=listing.id,
        title=listing.title,
        price=listing.price,
        price_unit=listing.price_unit,
        category_id=listing.category_id,
        district=listing.district,
        created_at=listing.created_at,
        photo=photo_url(cover.filename, thumb=True) if cover else None,
        is_favorite=listing.id in favorite_ids,
    )


def to_seller(owner: User, listing_count: int) -> SellerOut:
    return SellerOut(
        id=owner.id,
        name=owner.name,
        member_since=owner.created_at.year,
        phone_verified=owner.phone_verified,
        listing_count=listing_count,
    )


def to_detail(
    listing: Listing, owner: User, listing_count: int, is_favorite: bool
) -> ListingOut:
    return ListingOut(
        id=listing.id,
        title=listing.title,
        description=listing.description,
        price=listing.price,
        price_unit=listing.price_unit,
        category_id=listing.category_id,
        condition=listing.condition,
        district=listing.district,
        address=listing.address,
        lat=listing.lat,
        lng=listing.lng,
        status=listing.status,
        reject_reason=listing.reject_reason,
        views=listing.views,
        created_at=listing.created_at,
        photos=[
            PhotoOut(
                id=p.id,
                url=photo_url(p.filename),
                thumb_url=photo_url(p.filename, thumb=True),
                width=p.width,
                height=p.height,
            )
            for p in listing.photos
        ],
        specs=[SpecOut(label=s.label, value=s.value) for s in listing.specs],
        seller=to_seller(owner, listing_count),
        is_favorite=is_favorite,
    )
