from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles

app = FastAPI()

# Mount the 'build' folder to serve static files
app.mount("/", StaticFiles(directory="../build", html=True), name="static")
