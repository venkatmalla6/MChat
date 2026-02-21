from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from .models import Base

# SQLite database file will be created in the project root
DATABASE_URL = "sqlite:///./expenses.db"

# Create engine (connection factory)
engine = create_engine(
    DATABASE_URL,
    connect_args={"check_same_thread": False}   # Needed for SQLite + FastAPI
)

# Factory to create new database sessions
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Create all tables defined in models (if they don't exist)
Base.metadata.create_all(bind=engine)
