import pytest
import time
from fastapi.testclient import TestClient
from sqlalchemy import text
from app.main import app
from app.database import SessionLocal

client = TestClient(app)

# Fixture: clean users & expenses tables before/after every test
@pytest.fixture(autouse=True)
def clean_database():
    db = SessionLocal()
    try:
        db.execute(text("DELETE FROM expenses"))
        db.execute(text("DELETE FROM users"))
        db.commit()
    finally:
        db.close()
    yield


def test_read_root():
    """Root endpoint should return welcome message"""
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "Expense Tracker API is running"}


def test_create_user_success():
    """Create a new user successfully"""
    username = f"testuser_{int(time.time())}"
    response = client.post(
        "/users/",
        json={"username": username, "password": "StrongPass123!"}
    )
    assert response.status_code == 201
    data = response.json()
    assert data["username"] == username
    assert "id" in data


def test_create_user_duplicate():
    """Trying to create duplicate username should fail with 400"""
    username = f"dupuser_{int(time.time())}"
    
    # First user
    client.post("/users/", json={"username": username, "password": "StrongPass123!"})
    
    # Duplicate attempt
    response = client.post("/users/", json={"username": username, "password": "AnotherPass456!"})
    assert response.status_code == 400
    assert "Username already registered" in response.json()["detail"]


def test_login_success():
    """Register → Login → get valid JWT token"""
    username = f"loginuser_{int(time.time())}"
    
    # Register
    client.post("/users/", json={"username": username, "password": "LoginPass789!"})
    
    # Login
    response = client.post(
        "/token",
        data={"username": username, "password": "LoginPass789!"},
        headers={"Content-Type": "application/x-www-form-urlencoded"}
    )
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert data["token_type"] == "bearer"


def test_login_invalid_password():
    """Login with wrong password should return custom 401 message"""
    username = f"badpassuser_{int(time.time())}"
    
    # Register
    client.post("/users/", json={"username": username, "password": "CorrectPass"})
    
    # Wrong password
    response = client.post(
        "/token",
        data={"username": username, "password": "WrongPass"},
        headers={"Content-Type": "application/x-www-form-urlencoded"}
    )
    assert response.status_code == 401
    assert "Not authenticated or invalid token" in response.json()["detail"]


def test_create_expense_authenticated():
    """Create an expense after successful login"""
    username = f"expenseuser_{int(time.time())}"
    
    # Register user
    reg_resp = client.post("/users/", json={"username": username, "password": "ExpensePass456!"})
    assert reg_resp.status_code == 201, f"User creation failed: {reg_resp.text}"
    
    # Login
    login_resp = client.post(
        "/token",
        data={"username": username, "password": "ExpensePass456!"},
        headers={"Content-Type": "application/x-www-form-urlencoded"}
    )
    assert login_resp.status_code == 200, f"Login failed: {login_resp.text}"
    token = login_resp.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}
    
    # Valid expense (matches your current validation rules)
    expense_data = {
        "amount": 1250.50,
        "category": "Transport",
        "date": "2025-03-10",
        "description": "Cab to office"
    }
    response = client.post("/expenses/", json=expense_data, headers=headers)
    
    # Debug: show exact error if 422
    if response.status_code != 201:
        print(f"Expense creation failed with {response.status_code}: {response.text}")
    
    assert response.status_code == 201, f"Expected 201 but got {response.status_code}: {response.text}"
    data = response.json()
    assert data["amount"] == 1250.50
    assert data["category"] == "Transport"
    assert "id" in data


def test_create_expense_invalid_amount():
    """Negative amount should return 422 with validation message"""
    username = f"validuser_{int(time.time())}"
    
    # Register
    client.post("/users/", json={"username": username, "password": "ValidPass123"})
    
    # Login
    login_resp = client.post(
        "/token",
        data={"username": username, "password": "ValidPass123"},
        headers={"Content-Type": "application/x-www-form-urlencoded"}
    )
    token = login_resp.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}
    
    # Invalid (negative amount)
    invalid_data = {
        "amount": -100.0,
        "category": "Food",
        "date": "2025-03-15"
    }
    response = client.post("/expenses/", json=invalid_data, headers=headers)
    assert response.status_code == 422
    assert "Amount must be greater than zero" in str(response.json())
