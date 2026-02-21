from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from typing import List
from datetime import date, timedelta
from . import schemas, crud, database, auth

router = APIRouter()

def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()

# ───── User registration & login ─────
@router.post("/users/", response_model=schemas.User, status_code=201)
def create_user(user: schemas.UserCreate, db: Session = Depends(get_db)):
    db_user = crud.get_user_by_username(db, username=user.username)
    if db_user:
        raise HTTPException(status_code=400, detail="Username already registered")
    return crud.create_user(db=db, user=user)

@router.post("/token", response_model=schemas.Token)
def login_for_access_token(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db)
):
    user = auth.authenticate_user(db, form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token_expires = timedelta(minutes=auth.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = auth.create_access_token(
        data={"sub": user.username}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}

# ───── Protected expense routes ─────
expenses_router = APIRouter(prefix="/expenses", tags=["expenses"])

@expenses_router.post("/", response_model=schemas.Expense, status_code=201)
def create_expense(
    expense: schemas.ExpenseCreate,
    current_user: schemas.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    return crud.create_expense(db, expense, current_user.id)

@expenses_router.get("/", response_model=List[schemas.Expense])
def read_expenses(
    skip: int = 0,
    limit: int = 100,
    current_user: schemas.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    return crud.get_expenses(db, current_user.id, skip, limit)

@expenses_router.get("/{expense_id}", response_model=schemas.Expense)
def read_expense(
    expense_id: int,
    current_user: schemas.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    expense = crud.get_expense(db, expense_id, current_user.id)
    if expense is None:
        raise HTTPException(status_code=404, detail="Expense not found")
    return expense

@expenses_router.put("/{expense_id}", response_model=schemas.Expense)
def update_expense(
    expense_id: int,
    expense: schemas.ExpenseCreate,
    current_user: schemas.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    updated = crud.update_expense(db, expense_id, expense, current_user.id)
    if updated is None:
        raise HTTPException(status_code=404, detail="Expense not found")
    return updated

@expenses_router.delete("/{expense_id}", response_model=schemas.Expense)
def delete_expense(
    expense_id: int,
    current_user: schemas.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    deleted = crud.delete_expense(db, expense_id, current_user.id)
    if deleted is None:
        raise HTTPException(status_code=404, detail="Expense not found")
    return deleted

@expenses_router.get("/filter/", response_model=List[schemas.Expense])
def filter_expenses(
    category: str | None = None,
    start_date: date | None = None,
    end_date: date | None = None,
    current_user: schemas.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    return crud.get_filtered_expenses(db, current_user.id, category, start_date, end_date)

@expenses_router.get("/summary/monthly/")
def monthly_summary(
    year: int,
    month: int,
    current_user: schemas.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    total = crud.get_monthly_summary(db, current_user.id, year, month)
    return {"year": year, "month": month, "total_expense": total}

@expenses_router.get("/summary/categories/")
def category_totals(
    current_user: schemas.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    totals = crud.get_category_totals(db, current_user.id)
    return [{"category": cat, "total": total} for cat, total in totals]

router.include_router(expenses_router)
