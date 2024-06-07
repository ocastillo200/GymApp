from fastapi import FastAPI
import uvicorn
from routes.clients_route import router
from fastapi.middleware.cors import CORSMiddleware
app = FastAPI()

app.include_router(router) 

app.add_middleware(CORSMiddleware,
    allow_origins=["*"],  
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE"], 
    allow_headers=["*"],  
)

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)