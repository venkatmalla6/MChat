from typing import List, Optional, Tuple
from datetime import date
from sqlalchemy.orm import Session
from sqlalchemy import func, extract
from . import models, schemas
from .auth import get_password_hash

def create_user(db: Session, user: schemas.UserCreate):
    hashed_password = get_password_hash(user.password)
    db_user = models.User(username=user.username, hashed_password=hashed_password)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

def get_user_by_username(db: Session, username: str):
    return db.query(models.User).filter(models.User.username == username).first()

# Expense CRUD with real user_id
def create_expense(db: Session, expense: schemas.ExpenseCreate, user_id: int):
    db_expense = models.Expense(**expense.dict(), user_id=user_id)
    db.add(db_expense)
    db.commit()
    db.refresh(db_expense)
    return db_expense

def get_expenses(db: Session, user_id: int, skip: int = 0, limit: int = 100):
    return db.query(models.Expense).filter(models.Expense.user_id == user_id).offset(skip).limit(limit).all()

def get_expense(db: Session, expense_id: int, user_id: int):
    return db.query(models.Expense).filter(models.Expense.id == expense_id, models.Expense.user_id == user_id).first()

def update_expense(db: Session, expense_id: int, expense_update: schemas.ExpenseCreate, user_id: int):
    db_expense = get_expense(db, expense_id, user_id)
    if db_expense is None:
        return None
    update_data = expense_update.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_expense, key, value)
    db.commit()
    db.refresh(db_expense)
    return db_expense

def delete_expense(db: Session, expense_id: int, user_id: int):
    db_expense = get_expense(db, expense_id, user_id)
    if db_expense is None:
        return None
    db.delete(db_expense)
    db.commit()
    return db_expense

def get_filtered_expenses(db: Session, user_id: int, category: Optional[str] = None, start_date: Optional[date] = None, end_date: Optional[date] = None):
    query = db.query(models.Expense).filter(models.Expense.user_id == user_id)
    if category:
        query = query.filter(models.Expense.category == category)
    if start_date:
        query = query.filter(models.Expense.date >= start_date)
    if end_date:
        query = query.filter(models.Expense.date <= end_date)
    return query.all()

def get_monthly_summary(db: Session, user_id: int, year: int, month: int):
    total = db.query(func.sum(models.Expense.amount))\
             .filter(models.Expense.user_id == user_id,
                     extract('year', models.Expense.date) == year,
                     extract('month', models.Expense.date) == month)\
             .scalar()
    return float(total or 0.0)

def get_category_totals(db: Session, user_id: int):
    results = db.query(models.Expense.category, func.sum(models.Expense.amount))\
                .filter(models.Expense.user_id == user_id)\
                .group_by(models.Expense.category)\
                .all()
    return [(cat, float(total or 0.0)) for cat, total in results]
