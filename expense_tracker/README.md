# FastAPI Expense Tracker

A secure REST API for tracking personal expenses with user authentication, CRUD operations, filtering and summaries.

## Features
- User registration & JWT-based login
- Protected endpoints (only owners can access their expenses)
- Create, read, update, delete expenses
- Filter by category / date range
- Monthly expense summary
- Category-wise totals
- Input validation & custom error handling
- Basic pytest tests

## Tech Stack
- FastAPI
- SQLAlchemy + SQLite
- Pydantic v2
- JWT (python-jose)
- Password hashing (passlib[argon2])
- Testing: pytest + httpx

## Setup & Run (Development)

1. Clone the repository
```bash
git clone <your-repo-url>
cd expense_tracker
