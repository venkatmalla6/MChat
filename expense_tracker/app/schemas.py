from pydantic import BaseModel, field_validator, ConfigDict
from datetime import date
from typing import Optional

class ExpenseBase(BaseModel):
    amount: float
    category: str
    date: date
    description: Optional[str] = None

    model_config = ConfigDict(
        str_strip_whitespace=True,
        extra="forbid",
    )

    @field_validator('amount')
    @classmethod
    def amount_positive(cls, v: float):
        if v <= 0:
            raise ValueError("Amount must be greater than zero")
        return v

    @field_validator('category')
    @classmethod
    def category_valid(cls, v: str):
        v = v.strip()
        if not v:
            raise ValueError("Category cannot be empty or only whitespace")
        if not (1 <= len(v) <= 50):
            raise ValueError("Category must be between 1 and 50 characters")
        return v

    @field_validator('description')
    @classmethod
    def description_length(cls, v: Optional[str]):
        if v and len(v) > 500:
            raise ValueError("Description cannot exceed 500 characters")
        return v

class ExpenseCreate(ExpenseBase):
    pass

class Expense(ExpenseBase):
    id: int
    user_id: int

    class Config:
        from_attributes = True

class UserBase(BaseModel):
    username: str

class UserCreate(UserBase):
    password: str

class User(UserBase):
    id: int

    class Config:
        from_attributes = True

class Token(BaseModel):
    access_token: str
    token_type: str
