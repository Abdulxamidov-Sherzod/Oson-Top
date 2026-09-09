"""Ma'lumotnoma: kategoriyalar va tumanlar.

Bular Farg'ona viloyati uchun qat'iy ro'yxat — o'zgarishi kam, shuning uchun
bazada emas, kodda turadi. Flutter'dagi `mock_categories.dart` va
`mock_districts.dart` bilan bir xil bo'lishi shart.
"""

CATEGORIES: list[dict[str, str]] = [
    {"id": "phones", "label": "Telefonlar"},
    {"id": "cars", "label": "Avtomobil"},
    {"id": "realty", "label": "Uy-joy"},
    {"id": "electro", "label": "Elektronika"},
    {"id": "furniture", "label": "Mebel"},
    {"id": "household", "label": "Uy-roʻzgʻor"},
    {"id": "clothes", "label": "Kiyim"},
    {"id": "jobs", "label": "Ish oʻrni"},
    {"id": "services", "label": "Xizmatlar"},
    {"id": "animals", "label": "Hayvonlar"},
]

CATEGORY_IDS = {c["id"] for c in CATEGORIES}

DISTRICTS: list[str] = [
    "Fargʻona shahri",
    "Margʻilon",
    "Qoʻqon",
    "Quvasoy",
    "Rishton",
    "Beshariq",
    "Oltiariq",
    "Quva",
    "Yozyovon",
    "Bogʻdod",
    "Dangʻara",
    "Furqat",
    "Soʻx",
    "Toshloq",
    "Uchkoʻprik",
    "Oʻzbekiston tumani",
    "Fargʻona tumani",
    "Buvayda",
]

DISTRICT_SET = set(DISTRICTS)
