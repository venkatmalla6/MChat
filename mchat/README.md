# MChat 💬

A real-time direct messaging web application built with **React + Vite** on the frontend and **Cloudflare Workers + D1** on the backend.

---

## Features

- 🔐 **Authentication** — Register, login, logout with hashed passwords (SHA-256) and JWT-style tokens
- 🔁 **Remember Me** — Token saved to `sessionStorage` (clears on close) or `localStorage` (persists) based on user choice
- 🔑 **Password Reset** — OTP sent via email using the [Resend](https://resend.com) API
- 💬 **Direct Messaging** — Private one-to-one conversations using unique Chat IDs
- 📥 **Inbox Sidebar** — Lists all conversation partners with name + Chat ID, clickable to open
- ⭐ **Starred Conversations** — Pin important chats to the top of the sidebar
- 🔔 **Unread Badge** — Floating inbox button shows unread message count; clears when messages are read
- 🖼️ **Profile Picture Upload** — Click your avatar to upload a photo (compressed client-side and stored in D1)
- 👤 **Profile Page** — Displays name, email, join date, and your unique Chat ID

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | React 18, React Router v6, Vite |
| Styling | Vanilla CSS (no Tailwind) |
| Icons | [lucide-react](https://lucide.dev) |
| Backend | Cloudflare Workers |
| Database | Cloudflare D1 (SQLite) |
| Email | Resend API |

---

## Project Structure

```
MChat/
├── src/
│   ├── App.jsx           # Routing + ProtectedRoute / AuthRoute
│   ├── auth.js           # Token helpers (getToken, saveToken, clearToken)
│   ├── Chat.jsx          # Direct messaging UI + starred conversations
│   ├── Chat.css
│   ├── Home.jsx          # Landing / home page with unread badge FAB
│   ├── Home.css
│   ├── Login.jsx         # Login, register, forgot-password flows
│   ├── Login.css
│   ├── Profile.jsx       # User profile + avatar upload
│   ├── Profile.css
│   ├── Features.jsx
│   └── About.jsx
├── worker/
│   └── index.js          # Cloudflare Worker — all API endpoints
├── vite.config.js        # Dev proxy: /api → http://127.0.0.1:8787
└── wrangler.toml         # Cloudflare Worker config
```

---

## Getting Started

### Prerequisites

- Node.js ≥ 18
- [Wrangler CLI](https://developers.cloudflare.com/workers/wrangler/install-and-update/) — `npm install -g wrangler`
- A Cloudflare account with D1 enabled

### 1. Install dependencies

```bash
npm install
```

### 2. Set up the D1 database

Create the database and run migrations:

```bash
# Create D1 database (once)
wrangler d1 create mchat-db

# Apply schema (create tables)
wrangler d1 execute mchat-db --local --file=schema.sql
```

Ensure `wrangler.toml` references your database:

```toml
[[d1_databases]]
binding = "DB"
database_name = "mchat-db"
database_id = "<your-database-id>"
```

### 3. Set environment secrets

```bash
wrangler secret put RESEND_API_KEY
# Paste your Resend API key when prompted
```

### 4. Run locally

Open **two terminals**:

```bash
# Terminal 1 — Backend (Cloudflare Worker)
npx wrangler dev

# Terminal 2 — Frontend (Vite dev server)
npm start
```

Open [http://localhost:5173](http://localhost:5173) in your browser.

---

## API Endpoints

| Method | Path | Description |
|---|---|---|
| `POST` | `/api/register` | Register a new user |
| `POST` | `/api/login` | Login, returns token + chat_id |
| `POST` | `/api/forgot-password` | Send OTP to email |
| `POST` | `/api/verify-otp` | Verify OTP and reset password |
| `GET` | `/api/user` | Get current user profile |
| `POST` | `/api/upload-avatar` | Upload profile picture (base64) |
| `GET` | `/api/user-by-chatid` | Look up a user by their Chat ID |
| `GET` | `/api/messages?with=<email>` | Fetch DMs with a user (marks as read) |
| `POST` | `/api/messages` | Send a message |
| `GET` | `/api/messages/unread-count` | Count of unread messages |
| `GET` | `/api/conversations` | List of all conversation partners |

---

## Database Schema

```sql
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    name TEXT,
    chat_id TEXT UNIQUE,
    avatar_url TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE messages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    sender_email TEXT NOT NULL,
    sender_name TEXT,
    receiver_email TEXT NOT NULL,
    content TEXT NOT NULL,
    is_read INTEGER DEFAULT 0,
    created_at INTEGER NOT NULL
);
```

---

## How Direct Messaging Works

1. Every user gets a unique **Chat ID** (e.g. `MCH4F2A`) on registration
2. Share your Chat ID with someone so they can find you
3. In the chat page, click **+ New Chat** and enter their Chat ID
4. Messages are polled every **2 seconds** for real-time feel
5. Opening a conversation automatically **marks messages as read**

---

## License

MIT
