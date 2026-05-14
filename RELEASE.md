# Инструкция по сборке и релизу

## Android

### 1. Создать keystore (один раз)
```bash
keytool -genkey -v \
  -keystore android/upload-keystore.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias upload
```
Введёшь: страна (RU), имя, пароль. Запомни пароли — без них нельзя обновить приложение.

### 2. Создать key.properties
Положи файл `android/key.properties` (уже есть в выдаче):
```
storePassword=ВАШ_ПАРОЛЬ_KEYSTORE
keyPassword=ВАШ_ПАРОЛЬ_КЛЮЧА
keyAlias=upload
storeFile=../upload-keystore.jks
```
⚠️ Этот файл уже в .gitignore — не коммить его!

### 3. Настроить продакшн .env
```
API_URL=https://api.your-domain.ru
```

### 4. Собрать APK
```bash
flutter build apk --release
# Файл: build/app/outputs/flutter-apk/app-release.apk
```

Или AAB для Google Play:
```bash
flutter build appbundle --release
# Файл: build/app/outputs/bundle/release/app-release.aab
```

---

## Backend (деплой на сервер)

### Требования
- Python 3.11+
- PostgreSQL 15+
- Доменное имя + SSL сертификат (Let's Encrypt)

### Установка
```bash
cd backend
cp ../backend.env.example .env
# Заполни .env своими значениями

pip install -r requirements.txt

# Запуск
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

### Рекомендуется: запуск через systemd или Docker
```bash
# Проверка что API работает:
curl https://api.your-domain.ru/
# Должен вернуть: {"status":"ok","message":"Expo backend is running"}
```

---

## Чеклист перед релизом

- [ ] keystore создан и сохранён в надёжном месте
- [ ] key.properties заполнен
- [ ] .env с продакшн URL
- [ ] Бэкенд задеплоен на сервер с HTTPS
- [ ] BITRIX_WEBHOOK_URL настроен
- [ ] Тест: регистрация → вход → создание билета
- [ ] flutter build apk --release прошёл без ошибок
