from fastapi import FastAPI, HTTPException, Depends
import mysql.connector
from mysql.connector import Error
from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

app = FastAPI()

# Database connection configuration
db_config = {
    'host': 'localhost',
    'user': 'root',
    'password': 'yourpassword',
    'database': 'task_manager'
}

# Pydantic models for request/response validation
class UserCreate(BaseModel):
    username: str
    email: str

class UserResponse(UserCreate):
    user_id: int
    created_at: datetime

class TaskCreate(BaseModel):
    title: str
    description: Optional[str] = None
    status: Optional[str] = "pending"
    user_id: int

class TaskResponse(TaskCreate):
    task_id: int
    created_at: datetime
    updated_at: datetime

# Database connection helper
def get_db_connection():
    try:
        connection = mysql.connector.connect(**db_config)
        return connection
    except Error as e:
        print(f"Error connecting to MySQL: {e}")
        raise HTTPException(status_code=500, detail="Database connection error")

# CRUD Operations for Users
@app.post("/users/", response_model=UserResponse)
def create_user(user: UserCreate):
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)
    
    try:
        query = "INSERT INTO users (username, email) VALUES (%s, %s)"
        cursor.execute(query, (user.username, user.email))
        connection.commit()
        
        # Get the newly created user
        user_id = cursor.lastrowid
        cursor.execute("SELECT * FROM users WHERE user_id = %s", (user_id,))
        new_user = cursor.fetchone()
        
        return new_user
    except Error as e:
        connection.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        cursor.close()
        connection.close()

@app.get("/users/", response_model=List[UserResponse])
def read_users():
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)
    
    try:
        cursor.execute("SELECT * FROM users")
        users = cursor.fetchall()
        return users
    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()
        connection.close()

@app.get("/users/{user_id}", response_model=UserResponse)
def read_user(user_id: int):
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)
    
    try:
        cursor.execute("SELECT * FROM users WHERE user_id = %s", (user_id,))
        user = cursor.fetchone()
        if user is None:
            raise HTTPException(status_code=404, detail="User not found")
        return user
    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()
        connection.close()

@app.put("/users/{user_id}", response_model=UserResponse)
def update_user(user_id: int, user: UserCreate):
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)
    
    try:
        query = "UPDATE users SET username = %s, email = %s WHERE user_id = %s"
        cursor.execute(query, (user.username, user.email, user_id))
        connection.commit()
        
        if cursor.rowcount == 0:
            raise HTTPException(status_code=404, detail="User not found")
        
        cursor.execute("SELECT * FROM users WHERE user_id = %s", (user_id,))
        updated_user = cursor.fetchone()
        return updated_user
    except Error as e:
        connection.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        cursor.close()
        connection.close()

@app.delete("/users/{user_id}")
def delete_user(user_id: int):
    connection = get_db_connection()
    cursor = connection.cursor()
    
    try:
        cursor.execute("DELETE FROM users WHERE user_id = %s", (user_id,))
        connection.commit()
        
        if cursor.rowcount == 0:
            raise HTTPException(status_code=404, detail="User not found")
        
        return {"message": "User deleted successfully"}
    except Error as e:
        connection.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()
        connection.close()

# CRUD Operations for Tasks
@app.post("/tasks/", response_model=TaskResponse)
def create_task(task: TaskCreate):
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)
    
    try:
        # Verify user exists
        cursor.execute("SELECT 1 FROM users WHERE user_id = %s", (task.user_id,))
        if not cursor.fetchone():
            raise HTTPException(status_code=404, detail="User not found")
        
        query = """
        INSERT INTO tasks (title, description, status, user_id)
        VALUES (%s, %s, %s, %s)
        """
        cursor.execute(query, (task.title, task.description, task.status, task.user_id))
        connection.commit()
        
        # Get the newly created task
        task_id = cursor.lastrowid
        cursor.execute("SELECT * FROM tasks WHERE task_id = %s", (task_id,))
        new_task = cursor.fetchone()
        
        return new_task
    except Error as e:
        connection.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        cursor.close()
        connection.close()

@app.get("/tasks/", response_model=List[TaskResponse])
def read_tasks(user_id: Optional[int] = None):
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)
    
    try:
        if user_id:
            cursor.execute("SELECT * FROM tasks WHERE user_id = %s", (user_id,))
        else:
            cursor.execute("SELECT * FROM tasks")
        tasks = cursor.fetchall()
        return tasks
    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()
        connection.close()

@app.get("/tasks/{task_id}", response_model=TaskResponse)
def read_task(task_id: int):
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)
    
    try:
        cursor.execute("SELECT * FROM tasks WHERE task_id = %s", (task_id,))
        task = cursor.fetchone()
        if task is None:
            raise HTTPException(status_code=404, detail="Task not found")
        return task
    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()
        connection.close()

@app.put("/tasks/{task_id}", response_model=TaskResponse)
def update_task(task_id: int, task: TaskCreate):
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)
    
    try:
        # Verify task exists
        cursor.execute("SELECT 1 FROM tasks WHERE task_id = %s", (task_id,))
        if not cursor.fetchone():
            raise HTTPException(status_code=404, detail="Task not found")
        
        # Verify user exists
        cursor.execute("SELECT 1 FROM users WHERE user_id = %s", (task.user_id,))
        if not cursor.fetchone():
            raise HTTPException(status_code=404, detail="User not found")
        
        query = """
        UPDATE tasks 
        SET title = %s, description = %s, status = %s, user_id = %s
        WHERE task_id = %s
        """
        cursor.execute(query, (task.title, task.description, task.status, task.user_id, task_id))
        connection.commit()
        
        cursor.execute("SELECT * FROM tasks WHERE task_id = %s", (task_id,))
        updated_task = cursor.fetchone()
        return updated_task
    except Error as e:
        connection.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        cursor.close()
        connection.close()

@app.delete("/tasks/{task_id}")
def delete_task(task_id: int):
    connection = get_db_connection()
    cursor = connection.cursor()
    
    try:
        cursor.execute("DELETE FROM tasks WHERE task_id = %s", (task_id,))
        connection.commit()
        
        if cursor.rowcount == 0:
            raise HTTPException(status_code=404, detail="Task not found")
        
        return {"message": "Task deleted successfully"}
    except Error as e:
        connection.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()
        connection.close()
        