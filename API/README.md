# card-API

This repository is a Node.js/Express API (formerly a business-card OCR service). The OCR/OpenAI-based scan functionality has been removed.

Current features:
- JWT-based authentication (`admin` and `user` roles) with a unique 6-digit `code` per user.
- CRUD for `records` (contact entries) scoped to a user's `code`.
- CRUD for `files` (metadata) and an endpoint for dashboard binary uploads served at `/file-upload`.

This README explains how to set up, run, and use the API.

## Quick start

1. Clone the repo:

  git clone https://github.com/MenathP/card-API.git
  cd card-API

2. Install dependencies (Node.js and npm required):

  npm install

3. Configure environment

  - Create a `.env` file in the project root (or edit existing) and set:

    PORT=7001
    CONNECTION_STRING=<your-mongodb-connection-string>
    JWT_STRING=<your-jwt-secret>

4. Start the server (development):

  npm run dev

  - The server listens on the `PORT` set in `.env` (default 7001).

## Health check

- `GET /health` -> `{ status: "ok" }`

## Base URL
- Local (same machine): `http://localhost:7001`
- Android emulator: `http://10.0.2.2:7001`
- Device on same LAN: `http://<your-ip>:7001`

## Auth
- `POST /api/auth/login` — body: `{ username, password }` -> `{ token, user }`
- `POST /api/auth/login-code` — body: `{ code }` -> `{ token, user }`
- `POST /api/auth/register` — admin only (Bearer token)

Token: `Authorization: Bearer <jwt>`

## Me
- `GET /api/me` — get current user (returns user, records, files)

## Records (auth required)
- `GET /api/records` — list
- `POST /api/records` — create
- `GET /api/records/:id` — get
- `PATCH /api/records/:id` — update
- `DELETE /api/records/:id` — remove

## Files (auth required)
- `GET /api/files` — list
- `POST /api/files` — create
- `POST /api/files/upload` — dashboard binary uploads (form-data `files`)
- `GET /api/files/:id` — get
- `PATCH /api/files/:id` — update
- `DELETE /api/files/:id` — remove

## Seeding admin
Create/ensure an admin with a unique 6-digit code:
```
node scripts/seedAdmin.js
```
Default: username `admin`, password `admin@123`.

## Notes
- JWT secret is taken from `JWT_SECRET` or `JWT_STRING`.
- Rate limits are applied for login endpoints.

If you'd like, I can add a Postman collection or OpenAPI spec next.
# Card API

Fast Node.js/Express API with JWT auth and MongoDB. Supports 6-digit code login for mobile apps.

## Quick start

1. Install dependencies
```cmd
npm install
```

2. Configure environment
- Copy `.env.example` to `.env` and fill real values
- Required: `PORT`, `JWT_STRING` (or `JWT_SECRET`), `CONNECTION_STRING`

3. Run the API (dev)
```cmd
npm run dev
```

Health check: `GET /health` -> `{ status: "ok" }`

## Base URL
- Local (same machine): `http://localhost:7001`
- Android emulator: `http://10.0.2.2:7001`
- Device on same LAN: `http://<your-ip>:7001`

## Auth
- `POST /api/auth/login` — body: `{ username, password }` -> `{ token, user }`
- `POST /api/auth/login-code` — body: `{ code }` -> `{ token, user }`
- `POST /api/auth/register` — admin only (Bearer token)

Token: `Authorization: Bearer <jwt>`

## Me
- `GET /api/me` — get current user

## Records (auth required)
- `GET /api/records` — list
- `POST /api/records` — create
- `GET /api/records/:id` — get
- `PATCH /api/records/:id` — update
- `DELETE /api/records/:id` — remove

Fields example:
```json
{
  "code": "123456",
  "name": "John Doe",
  "title": "Engineer",
  "phoneNumbers": ["+123456789"],
  "mails": ["john@example.com"],
  "website": "https://example.com",
  "company": "Acme",
  "photo": "https://..."
}
```

## Files (auth required)
- `GET /api/files` — list
- `POST /api/files` — create
- `GET /api/files/:id` — get
- `PATCH /api/files/:id` — update
- `DELETE /api/files/:id` — remove

Fields example:
```json
{
  "code": "123456",
  "mail": "hello@example.com",
  "mailSubject": "Subject",
  "mailBody": "Body",
  "fileLinks": ["https://...", "https://..."]
}
```

## Seeding admin
Create/ensure an admin with a unique 6-digit code:
```cmd
node scripts/seedAdmin.js
```
Default: username `admin`, password `admin@123`.

## Notes
- JWT secret is taken from `JWT_SECRET` or `JWT_STRING`.
- Rate limits are applied for login endpoints.
