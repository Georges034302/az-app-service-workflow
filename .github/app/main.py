from fastapi import FastAPI, HTTPException
import json
import os

app = FastAPI()

# Ensure the correct path to data.json regardless of working directory
data_path = os.path.join(os.path.dirname(__file__), "data.json")
with open(data_path) as f:
    users = json.load(f)

@app.get("/users")
def get_users():
    return users

@app.get("/users/{user_id}")
def get_user(user_id: int):
    for user in users:
        if user["id"] == user_id:
            return user
    raise HTTPException(status_code=404, detail="User not found")
