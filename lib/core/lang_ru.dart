/// Ruscha lug'at. Kalit — koddagi o'zbekcha matnning o'zi.
///
/// Kirillcha lotinchadan mexanik o'giriladi, ruscha esa shu yerdan olinadi.
/// Lug'atda yo'q matn `lang.dart` dagi naqshlar orqali o'tadi (sana, narx,
/// sonli iboralar), u ham topmasa — matn lotincha qoladi.
const ruDictionary = <String, String>{
  // --- Umumiy ---
  'Orqaga': 'Назад',
  'Bekor qilish': 'Отмена',
  'Davom etish': 'Продолжить',
  'Qaytadan': 'Ещё раз',
  'Tozalash': 'Очистить',
  'Tayyor': 'Готово',
  'Qoʻllash': 'Применить',
  'Olib tashlash': 'Удалить',
  'Oʻzgartirish': 'Изменить',
  'Chiqish': 'Выйти',
  'Chiqasizmi?': 'Выйти из аккаунта?',
  'Qaytadan kirish uchun Telegram orqali tasdiqlash kerak boʻladi.':
      'Чтобы войти снова, потребуется подтверждение через Telegram.',
  'Til': 'Язык',
  'Sozlamalar': 'Настройки',
  'Hammasi shu': 'Это всё',
  'asosiy': 'главное',
  ' · ixtiyoriy': ' · необязательно',

  // --- Pastki menyu ---
  'Bosh sahifa': 'Главная',
  'Eʼlon berish': 'Разместить',
  'Profil': 'Профиль',

  // --- Bosh sahifa va qidiruv ---
  'Nima qidiryapsiz?': 'Что ищете?',
  'Yangi eʼlonlar': 'Новые объявления',
  'Fargʻona viloyati eʼlonlari': 'Объявления Ферганской области',
  'Barcha kategoriyalar': 'Все категории',
  'Koʻp qidiriladigan': 'Часто ищут',
  'Soʻnggi qidiruvlar': 'Недавние запросы',
  'Kategoriya': 'Категория',
  'Tuman': 'Район',
  'Narx': 'Цена',
  'Holati': 'Состояние',
  'Farqi yoʻq': 'Не важно',
  'Filtrlarni tozalash': 'Сбросить фильтры',
  'Filtrni tozalash': 'Сбросить фильтр',
  'Hech narsa topilmadi': 'Ничего не найдено',
  'Boshqa soʻz bilan qidirib koʻring yoki filtrlarni tozalang.':
      'Попробуйте другой запрос или сбросьте фильтры.',
  'Bu kategoriyada hozircha eʼlon yoʻq. Boshqasini tanlab koʻring.':
      'В этой категории пока нет объявлений. Выберите другую.',
  'Bittasini boʻsh qoldirsangiz ham boʻladi.':
      'Одно из полей можно оставить пустым.',

  // --- Saralash va holat ---
  'Eng yangi': 'Сначала новые',
  'Arzonidan': 'Сначала дешёвые',
  'Qimmatidan': 'Сначала дорогие',
  'Yangi': 'Новое',
  'Ishlatilgan': 'Б/у',
  'Aktiv': 'Активно',
  'Moderatsiyada': 'На модерации',
  'Qaytarilgan': 'Отклонено',
  'Muddati tugagan': 'Срок истёк',
  'Kelishiladi': 'Договорная',
  'soʻm': 'сум',

  // --- Eʼlon sahifasi ---
  'Eʼlon ochilmadi': 'Не удалось открыть объявление',
  'Eʼlon topilmadi': 'Объявление не найдено',
  'Maʼlumotlar': 'Характеристики',
  'Tavsif': 'Описание',
  'Oʻxshash eʼlonlar': 'Похожие объявления',
  'Raqam tasdiqlangan': 'Номер подтверждён',
  'Raqamni koʻrsatish': 'Показать номер',
  'Xabar': 'Написать',
  'Ehtiyot boʻling. ': 'Будьте осторожны. ',
  'Oldindan pul oʻtkazmang. Mahsulotni koʻrmasdan kartaga toʻlov qilmang — kelishuv joyida boʻlsin.':
      'Не переводите деньги заранее. Не платите на карту, не увидев товар — договаривайтесь на месте.',
  'Xaritada taxminiy hudud koʻrsatilgan.':
      'На карте показан примерный район.',
  'Xaritada ochish': 'Открыть на карте',
  'Xaritani ochadigan ilova topilmadi': 'Не найдено приложение для открытия карты',

  // --- Eʼlon berish ---
  '1-qadam / 2': 'Шаг 1 / 2',
  '2-qadam / 2': 'Шаг 2 / 2',
  'Rasmlar': 'Фото',
  'Rasm qoʻshish': 'Добавить фото',
  'Suratga olish': 'Сделать фото',
  'Galereyadan tanlash': 'Выбрать из галереи',
  'Birinchi rasm asosiy — lentada shu koʻrinadi.':
      'Первое фото главное — оно видно в ленте.',
  'Sarlavha': 'Заголовок',
  'Sarlavhani yozing': 'Введите заголовок',
  'Masalan: Yumshoq burchak divan': 'Например: Мягкий угловой диван',
  'Mahsulot holati, xususiyatlari, nima uchun sotayotganingiz…':
      'Состояние товара, характеристики, почему продаёте…',
  'Narx kelishiladi': 'Цена договорная',
  'Narxni kiriting yoki «kelishiladi» ni belgilang':
      'Укажите цену или отметьте «договорная»',
  'Kamida bitta rasm qoʻshing': 'Добавьте хотя бы одно фото',
  'Rasmlar yuklanmoqda, kuting': 'Фото загружаются, подождите',
  'Rasm yuklanmadi, qaytadan urining': 'Фото не загрузилось, попробуйте ещё раз',
  'Joylashuv': 'Местоположение',
  'Xaritada belgilash': 'Отметить на карте',
  'Aniq nuqta ixtiyoriy — faqat tumanni qoldirsangiz ham boʻladi.':
      'Точка на карте необязательна — можно указать только район.',
  'Koʻrib chiqing': 'Проверьте',
  'Eʼloningiz lentada xaridorlarga shunday koʻrinadi.':
      'Так ваше объявление увидят покупатели в ленте.',
  'Aloqa uchun Telegramda tasdiqlagan raqamingiz ishlatiladi. U eʼlonda yopiq turadi.':
      'Для связи используется номер, подтверждённый в Telegram. В объявлении он скрыт.',
  'Moderatsiyadan oʻtgach eʼlon saytda paydo boʻladi — odatda 15 daqiqa. Tayyor boʻlganda bildirishnoma keladi.':
      'После модерации объявление появится на сайте — обычно 15 минут. Когда всё будет готово, придёт уведомление.',
  'Tasdiqlab joylash': 'Подтвердить и разместить',
  'Eʼlon yuborildi': 'Объявление отправлено',
  'Moderator tekshirgach eʼloningiz saytda paydo boʻladi. Tayyor boʻlganda bildirishnoma keladi.':
      'После проверки модератором объявление появится на сайте. Когда всё будет готово, придёт уведомление.',
  'Asosiy sahifaga': 'На главную',

  'Eʼlonni tahrirlash': 'Редактировать объявление',
  'Tahrirlash': 'Редактировать',
  'Saqlash': 'Сохранить',
  'Saqlanmoqda…': 'Сохраняем…',
  'Oʻzgarishlar saqlandi': 'Изменения сохранены',
  'Eʼlon lentada yangilandi.': 'Объявление обновлено в ленте.',
  'Matn yoki rasm oʻzgargani uchun eʼlon qaytadan tekshiruvga yuborildi.':
      'Текст или фото изменились, поэтому объявление отправлено на повторную проверку.',
  'Eʼlonlarimga qaytish': 'К моим объявлениям',
  'Oʻchirish': 'Удалить',
  'Eʼlon oʻchirilsinmi?': 'Удалить объявление?',
  'Bu amalni orqaga qaytarib boʻlmaydi.': 'Это действие нельзя отменить.',

  // --- Xarita ---
  'Xaritani suring': 'Двигайте карту',
  'Manzil aniqlanmoqda…': 'Определяем адрес…',
  'Manzil topilmadi': 'Адрес не найден',
  'Shu joyni tanlash': 'Выбрать это место',
  'Eʼlonda taxminiy hudud koʻrsatiladi, aniq uy raqami emas.':
      'В объявлении показывается примерный район, а не точный адрес.',
  'Qurilmada joylashuv xizmati oʻchiq': 'Геолокация на устройстве выключена',
  'Joylashuvga ruxsat berilmadi': 'Доступ к геолокации не разрешён',
  'Joylashuvga ruxsat yopiq — Sozlamalardan oching':
      'Доступ к геолокации закрыт — откройте в Настройках',
  'Joylashuv aniqlanmadi, qaytadan urinib koʻring':
      'Не удалось определить геолокацию, попробуйте ещё раз',

  // --- Profil ---
  'Hali kirmadingiz': 'Вы не вошли',
  'Kirmagansiz': 'Вы не вошли',
  'Eʼlon berish va saqlash uchun Telegram orqali kiring.':
      'Войдите через Telegram, чтобы размещать и сохранять объявления.',
  'Telegram orqali kirish': 'Войти через Telegram',
  'Telegram ochilmadi': 'Не удалось открыть Telegram',
  'Telegramda «Raqamni ulashish» tugmasini bosing — shundan keyin bu yerga oʻzi qaytadi.':
      'Нажмите в Telegram кнопку «Поделиться номером» — после этого вы вернётесь сюда автоматически.',
  'Kirish uchun Telegram yetarli — SMS kutish shart emas. Bot raqamingizni soʻraydi, u eʼlonlaringizda xaridorlar bogʻlanishi uchun kerak.':
      'Для входа достаточно Telegram — SMS ждать не нужно. Бот запросит ваш номер, он нужен, чтобы покупатели могли связаться с вами.',
  'Keyinroq — avval eʼlonlarni koʻraman': 'Позже — сначала посмотрю объявления',
  'Havola eskirdi. Qaytadan urinib koʻring.': 'Ссылка устарела. Попробуйте ещё раз.',
  'Mening eʼlonlarim': 'Мои объявления',
  'Eʼlonlaringiz yoʻq': 'У вас нет объявлений',
  'Birinchi eʼloningizni joylang — 2 daqiqa vaqt oladi.':
      'Разместите первое объявление — это займёт 2 минуты.',
  'Saqlangan eʼlonlar': 'Сохранённые',
  'Saqlangan eʼlonlar yoʻq': 'Нет сохранённых объявлений',
  'Eʼlon yoqqan boʻlsa, yurakcha belgisini bosing — shu yerda saqlanadi.':
      'Понравилось объявление — нажмите на сердечко, оно сохранится здесь.',
  'Eʼlonlarni koʻrish': 'Смотреть объявления',
  'Aktiv eʼlon': 'Активных',
  'Koʻrishlar': 'Просмотры',
  'Saqlanganlar': 'Сохранённые',
  'Foydalanuvchi': 'Пользователь',

  // --- Profilni tahrirlash ---
  'Profilni tahrirlash': 'Редактировать профиль',
  'Ism': 'Имя',
  'Ismingiz': 'Ваше имя',
  'Ismingizni yozing': 'Введите имя',
  'Eʼlonlaringizda shu ism koʻrinadi': 'Это имя увидят в ваших объявлениях',
  'Tanlanmagan': 'Не выбрано',
  'Telefon raqami': 'Номер телефона',
  'Raqam Telegram orqali tasdiqlangan — uni ilovadan oʻzgartirib boʻlmaydi.':
      'Номер подтверждён через Telegram — изменить его в приложении нельзя.',
  'Profil saqlandi': 'Профиль сохранён',
  'Avval tizimga kiring': 'Сначала войдите',

  // --- Bildirishnomalar ---
  'Bildirishnomalar': 'Уведомления',
  'Bildirishnomalar yoʻq': 'Уведомлений нет',
  'Eʼloningiz tasdiqlanganda yoki xaridor bogʻlanganda shu yerda xabar chiqadi.':
      'Здесь появятся уведомления, когда объявление одобрят или с вами свяжется покупатель.',
  'Qidiruvni saqlab qoʻysangiz, mos eʼlon chiqqanda birinchi boʻlib xabar beramiz.':
      'Сохраните поиск — сообщим первыми, когда появится подходящее объявление.',
  'Oʻqildi': 'Прочитано',

  // --- Xatolar ---
  'Serverga ulanib boʻlmadi': 'Не удалось подключиться к серверу',
  'Serverda xatolik yuz berdi': 'Ошибка на сервере',
  'Internetga ulanib boʻlmadi. Aloqani tekshiring.':
      'Нет подключения к интернету. Проверьте связь.',
  'Internetni tekshiring va qaytadan urinib koʻring.':
      'Проверьте интернет и попробуйте ещё раз.',
  'Yuklab boʻlmadi': 'Не удалось загрузить',
  'Joylab boʻlmadi': 'Не удалось разместить',

  // --- Kategoriyalar (backend/app/reference.py bilan bir xil) ---
  'Telefonlar': 'Телефоны',
  'Avtomobil': 'Автомобили',
  'Uy-joy': 'Жильё',
  'Elektronika': 'Электроника',
  'Mebel': 'Мебель',
  'Uy-roʻzgʻor': 'Для дома',
  'Kiyim': 'Одежда',
  'Ish oʻrni': 'Работа',
  'Xizmatlar': 'Услуги',
  'Hayvonlar': 'Животные',

  // --- Tumanlar ---
  'Fargʻona viloyati': 'Ферганская область',
  'Fargʻona shahri': 'Фергана',
  'Fargʻona tumani': 'Ферганский район',
  'Margʻilon': 'Маргилан',
  'Qoʻqon': 'Коканд',
  'Quvasoy': 'Кувасай',
  'Rishton': 'Риштан',
  'Beshariq': 'Бешарык',
  'Oltiariq': 'Алтыарык',
  'Quva': 'Кува',
  'Yozyovon': 'Язъяван',
  'Bogʻdod': 'Багдад',
  'Dangʻara': 'Дангара',
  'Furqat': 'Фуркат',
  'Soʻx': 'Сох',
  'Toshloq': 'Ташлак',
  'Uchkoʻprik': 'Учкуприк',
  'Oʻzbekiston tumani': 'Узбекистанский район',
  'Buvayda': 'Бувайда',

  // --- Narx birligi ---
  'oy': 'мес.',
  'kun': 'день',
  'soat': 'час',

  // --- Vaqt ---
  'hozir': 'только что',
  'Kecha': 'Вчера',
};

/// O'zbekcha oy nomi → ruscha (sanada qaratqich kelishigida)
const ruMonths = <String, String>{
  'yanvar': 'января', 'fevral': 'февраля', 'mart': 'марта',
  'aprel': 'апреля', 'may': 'мая', 'iyun': 'июня',
  'iyul': 'июля', 'avgust': 'августа', 'sentabr': 'сентября',
  'oktabr': 'октября', 'noyabr': 'ноября', 'dekabr': 'декабря',
};
