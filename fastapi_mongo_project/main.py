from fastapi import FastAPI
from routes.clients_route import router
app = FastAPI()

app.include_router(router) 