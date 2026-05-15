import 'language_provider.dart';

class AppStrings {
  const AppStrings(this.languageCode);

  final String languageCode;

  bool get isRu => languageCode == 'ru';

  static AppStrings fromCode(String? languageCode) {
    return AppStrings(normalizeLanguageCode(languageCode) ?? defaultLanguageCode);
  }

  String get appName => 'Word Mobile';
  String get chooseLanguage => isRu ? 'Выберите язык' : 'Тилди тандаңыз';
  String get chooseLanguageSubtitle => isRu
      ? 'Интерфейс и учебные материалы будут открываться на выбранном языке.'
      : 'Интерфейс жана окуу материалдары тандалган тилде ачылат.';
  String get kyrgyz => isRu ? 'Кыргызский' : 'Кыргызча';
  String get russian => isRu ? 'Русский' : 'Орусча';
  String get continueLabel => isRu ? 'Продолжить' : 'Улантуу';
  String get splashSubtitle => isRu
      ? 'Учите английские слова легче и повторяйте каждый день.'
      : 'Англисче сөздөрдү жеңил үйрөнүп, күн сайын кайталап туруңуз.';
  String get login => isRu ? 'Вход' : 'Кирүү';
  String get register => isRu ? 'Регистрация' : 'Катталуу';
  String get password => isRu ? 'Пароль' : 'Сырсөз';
  String get yourPassword => isRu ? 'Ваш пароль' : 'Сырсөзүңүз';
  String get newPassword => isRu ? 'Новый пароль' : 'Жаңы сырсөз';
  String get repeatPassword => isRu ? 'Повторите пароль' : 'Сырсөздү кайталаңыз';
  String get name => isRu ? 'Имя' : 'Атыңыз';
  String get enterName => isRu ? 'Введите имя' : 'Атыңызды жазыңыз';
  String get googleLogin => isRu ? 'Войти через Google' : 'Google менен кирүү';
  String get noAccount => isRu ? 'Нет аккаунта?' : 'Аккаунтуңуз жокпу?';
  String get haveAccount => isRu ? 'Уже есть аккаунт?' : 'Аккаунтуңуз барбы?';
  String get or => isRu ? 'или' : 'же';
  String get enterEmail => isRu ? 'Введите email' : 'Email жазыңыз';
  String get validEmail => isRu ? 'Введите корректный email' : 'Туура email жазыңыз';
  String get enterPassword => isRu ? 'Введите пароль' : 'Сырсөз жазыңыз';
  String get minPassword => isRu ? 'Минимум 6 символов' : 'Кеминде 6 белги болсун';
  String get repeatPasswordError =>
      isRu ? 'Повторите пароль' : 'Сырсөздү кайталаңыз';
  String get passwordsDoNotMatch =>
      isRu ? 'Пароли не совпадают' : 'Сырсөздөр дал келген жок';
  String get sessionExpired =>
      isRu ? 'Сессия завершена. Войдите снова.' : 'Сессия аяктады. Кайра кириңиз.';
  String get badCredentials =>
      isRu ? 'Email или пароль неверный.' : 'Email же сырсөз туура эмес.';
  String get googleNotConfigured => isRu
      ? 'Вход через Google пока не настроен. Добавьте GOOGLE_WEB_CLIENT_ID или GOOGLE_SERVER_CLIENT_ID.'
      : 'Google менен кирүү азырынча жөндөлгөн эмес. GOOGLE_WEB_CLIENT_ID же GOOGLE_SERVER_CLIENT_ID кошуңуз.';
  String get googleIdTokenMissing => isRu
      ? 'Google не вернул idToken. Проверьте OAuth Client ID и web-настройки.'
      : 'Google idToken кайтарылган жок. OAuth Client ID жана web жөндөөлөрүн текшериңиз.';
  String get retry => isRu ? 'Повторить' : 'Кайра аракет кылуу';
  String get tests => isRu ? 'Тесты' : 'Тесттер';
  String get categories => isRu ? 'Категории' : 'Категориялар';
  String get categoriesLoading =>
      isRu ? 'Категории загружаются...' : 'Категориялар жүктөлүп жатат...';
  String get categoriesLoadFailed =>
      isRu ? 'Не удалось загрузить категории' : 'Категорияларды жүктөө мүмкүн болгон жок';
  String get noCategories =>
      isRu ? 'Категории пока не добавлены' : 'Категориялар азырынча кошула элек';
  String get noExplanationCategories =>
      isRu ? 'Категории пока не добавлены' : 'Азырынча категория кошула элек';
  String get image => isRu ? 'Изображение' : 'Сүрөт';
  String get start => isRu ? 'Начать' : 'Баштоо';
  String wordCount(int count) => isRu ? '$count слов' : '$count сөз';
  String get flashcards => isRu ? 'Карточки' : 'Карталар';
  String get flashcardLoading => isRu ? 'Карточка загружается...' : 'Карта жүктөлүп жатат...';
  String get noFlashcards => isRu ? 'Пока нет карточек' : 'Азырынча карта жок';
  String get flashcardLoadFailed =>
      isRu ? 'Не удалось загрузить карточку' : 'Картаны жүктөө мүмкүн болгон жок';
  String get nextFlashcard => isRu ? 'Следующая карточка' : 'Кийинки карта';
  String get english => isRu ? 'Английский' : 'Англисче';
  String get currentLanguageName => isRu ? 'Русский' : 'Кыргызча';
  String get explanations => isRu ? 'Объяснения' : 'Түшүндүрмө';
  String get words => isRu ? 'Слова' : 'Сөздөр';
  String get wordsLoading => isRu ? 'Слова загружаются...' : 'Сөздөр жүктөлүп жатат...';
  String get wordsLoadFailed =>
      isRu ? 'Не удалось загрузить слова' : 'Сөздөрдү жүктөө мүмкүн болгон жок';
  String get openExplanation =>
      isRu ? 'Откройте объяснение' : 'Түшүндүрмөнү ачып көрүңүз';
  String get noCategoryExplanations => isRu
      ? 'В этой категории пока нет объяснений'
      : 'Бул категорияда азырынча түшүндүрмө жок';
  String get explanationLoading =>
      isRu ? 'Объяснение загружается...' : 'Түшүндүрмө жүктөлүп жатат...';
  String get explanationLoadFailed =>
      isRu ? 'Не удалось загрузить объяснение' : 'Түшүндүрмөнү жүктөө мүмкүн болгон жок';
  String get noWordExplanation => isRu
      ? 'Информация по этому слову пока не добавлена'
      : 'Бул сөз боюнча маалымат азырынча кошула элек';
  String get whatIs => isRu ? 'Что это?' : 'Бул эмне?';
  String get meaning => isRu ? 'Значение' : 'Мааниси';
  String get usage => isRu ? 'Использование' : 'Колдонулушу';
  String get examples => isRu ? 'Примеры' : 'Мисалдар';
  String get hint => isRu ? 'Подсказка' : 'Кеңеш';
  String get test => isRu ? 'Тест' : 'Тест';
  String get testPreparing => isRu ? 'Тест готовится...' : 'Тест даярдалып жатат...';
  String get testStartFailed =>
      isRu ? 'Не удалось начать тест' : 'Тестти баштоо мүмкүн болгон жок';
  String questionNumber(int number) => isRu ? 'Вопрос $number' : 'Суроо $number';
  String get englishWord => isRu ? 'Английское слово' : 'Англисче сөз';
  String get markedUnknown =>
      isRu ? 'Отмечено как неизвестное' : 'Белгисиз деп белгиленди';
  String get dontKnow => isRu ? 'Не знаю' : 'Билбейм';
  String get correct => isRu ? 'Верно' : 'Туура';
  String get incorrect => isRu ? 'Неверно' : 'Туура эмес';
  String score(int score) => isRu ? 'Верно: $score' : 'Туура: $score';
  String get resultLoading =>
      isRu ? 'Результат загружается...' : 'Жыйынтык жүктөлүп жатат...';
  String get resultLoadFailed =>
      isRu ? 'Не удалось загрузить результат' : 'Жыйынтыкты жүктөө мүмкүн болгон жок';
  String get testFinished => isRu ? 'Тест завершен' : 'Тест аяктады';
  String get correctAnswers => isRu ? 'верных ответов' : 'туура жооп';
  String get result => isRu ? 'Результат' : 'Жыйынтык';
  String get bestScore => isRu ? 'Рекорд' : 'Рекорд';
  String get restart => isRu ? 'Начать заново' : 'Кайра баштоо';
  String get goToFlashcards => isRu ? 'Перейти к карточкам' : 'Карталарга өтүү';
  String get backToCategories =>
      isRu ? 'Вернуться к категориям' : 'Категорияларга кайтуу';
  String get unknownWords => isRu ? 'Неизвестные слова' : 'Белгисиз сөздөр';
  String get unknownWordsLoading =>
      isRu ? 'Слова загружаются...' : 'Сөздөр жүктөлүп жатат...';
  String get unknownWordsLoadFailed => isRu
      ? 'Не удалось загрузить неизвестные слова'
      : 'Белгисиз сөздөрдү жүктөө мүмкүн болгон жок';
  String get great => isRu ? 'Отлично!' : 'Сонун!';
  String get goodWork => isRu ? 'Хорошая работа!' : 'Жакшы иш!';
  String get practiceMore => isRu ? 'Попробуйте еще' : 'Дагы машыгып көрүңүз';
  String get noUnknownWords => isRu ? 'Неизвестных слов нет' : 'Белгисиз сөз жок';
  String get profile => isRu ? 'Профиль' : 'Профиль';
  String get profileSubtitle =>
      isRu ? 'Аккаунт и текущая сессия' : 'Аккаунтуңуз жана учурдагы сессия';
  String get profileLoading =>
      isRu ? 'Профиль загружается...' : 'Профиль жүктөлүп жатат...';
  String get profileLoadFailed =>
      isRu ? 'Не удалось загрузить профиль' : 'Профилди жүктөө мүмкүн болгон жок';
  String get accountActive => isRu ? 'Аккаунт активен' : 'Аккаунт активдүү';
  String get accountActiveSubtitle => isRu
      ? 'Можно продолжать обучение и практику.'
      : 'Окууну жана машыгууну улантсаңыз болот.';
  String get appLanguage => isRu ? 'Язык приложения' : 'Колдонмонун тили';
  String get languageSaved => isRu ? 'Язык обновлен' : 'Тил жаңыртылды';
  String get logout => isRu ? 'Выйти' : 'Чыгуу';
  String get basicDescription =>
      isRu ? 'Базовые слова для повседневной практики.' : 'Күнүмдүк керектүү негизги сөздөр.';
  String get travelDescription =>
      isRu ? 'Слова, которые часто нужны в путешествии.' : 'Саякатта көп колдонулуучу сөздөр.';
  String get foodDescription =>
      isRu ? 'Слова о еде и повседневных продуктах.' : 'Тамак-аш жана күнүмдүк азык сөздөрү.';
  String get verbsDescription =>
      isRu ? 'Подборка часто используемых глаголов.' : 'Көп колдонулган этиштер жыйнагы.';
  String get fallbackDescription1 =>
      isRu ? 'Слова для легкого повторения.' : 'Жеңил кайталоо үчүн сөздөр.';
  String get fallbackDescription2 =>
      isRu ? 'Удобный набор для запоминания.' : 'Эсте сактоого ыңгайлуу топтом.';
  String get fallbackDescription3 =>
      isRu ? 'Слова для следующего шага.' : 'Кийинки кадамга ылайык сөздөр.';
  String get verbsExplanation =>
      isRu ? 'Посмотрите глаголы с примерами.' : 'Этиштерди мисалдары менен караңыз.';
  String get travelExplanation =>
      isRu ? 'Набор слов для путешествий.' : 'Саякатка керектүү сөздөр топтому.';
  String get foodExplanation =>
      isRu ? 'Слова, связанные с едой.' : 'Тамак-ашка байланышкан сөздөр.';
  String get basicExplanation =>
      isRu ? 'Быстро повторите базовые слова.' : 'Негизги сөздөрдү тез кайталаңыз.';
  String get explanationFallback1 =>
      isRu ? 'Важные слова по теме.' : 'Тема боюнча маанилүү сөздөр.';
  String get explanationFallback2 =>
      isRu ? 'Слова для повседневного использования.' : 'Күнүмдүк колдонулган сөздөр.';
  String get explanationFallback3 =>
      isRu ? 'Подборка простых объяснений.' : 'Жеңил түшүндүрмөлөр жыйнагы.';
}
