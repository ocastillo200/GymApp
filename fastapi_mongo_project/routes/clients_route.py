from fastapi import APIRouter
from models.client import Client
from bson.objectid import ObjectId
from conifg.database import collection_clients
from schema.schemas import list_clients, serial_client
router = APIRouter()

@router.get("/")
async def get_clients():
    clients = list_clients(collection_clients.find())
    return clients

@router.post("/")
async def create_client(client: Client):
    collection_clients.insert_one(dict(client))
    return client

@router.get("/{id}")
async def find_client(id: str):
    client = serial_client(collection_clients.find_one({"_id": ObjectId(id)}))
    return client

@router.put("/{id}")
async def update_client(id: str, client: Client):
    collection_clients.find_one_and_update({"_id": ObjectId(id)}, {"$set": dict(client)})
    return client

@router.delete("/{id}")
async def delete_client(id: str):
    collection_clients.find_one_and_delete({"_id": ObjectId(id)})
    return {"message": "client deleted successfully!"}

