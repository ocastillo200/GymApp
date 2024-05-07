from http.client import HTTPException
from fastapi import APIRouter
from models.client import Client
from models.routine import Routine
from bson.objectid import ObjectId
from conifg.database import collection_clients, collection_routines
from schema.schemas import list_clients, serial_client, list_routines, serial_routine
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

@router.post("/clients/{client_id}/routines/")
async def create_routine_for_client(client_id: str, routine: Routine):
    inserted_routine = collection_routines.insert_one(routine.model_dump())
    routine_id = str(inserted_routine.inserted_id)
    client = collection_clients.find_one({"_id": ObjectId(client_id)})
    if client is None:
        raise HTTPException(status_code=404, detail="Client not found")
    collection_clients.update_one(
        {"_id": ObjectId(client_id)},
        {"$addToSet": {"idroutines": routine_id}}
    )
    return routine

@router.get("/clients/{client_id}/routines/")
async def get_client_routines(client_id: str):
    client = collection_clients.find_one({"_id": ObjectId(client_id)})
    if client is None:
        raise HTTPException(status_code=404, detail="Client not found")
    client_routines_ids = client.get("idroutines", [])
    client_routines = []
    for routine_id in client_routines_ids:
        routine = collection_routines.find_one({"_id": ObjectId(routine_id)})
        if routine:
            client_routines.append(routine)
    return list_routines(client_routines)

@router.delete("/clients/{client_id}/routines/{routine_id}/")
async def delete_client_routine(client_id: str, routine_id: str):
    client = collection_clients.find_one({"_id": ObjectId(client_id)})
    if client is None:
        raise HTTPException(status_code=404, detail="Client not found")

    routine = collection_routines.find_one({"_id": ObjectId(routine_id)})
    if routine is None:
        raise HTTPException(status_code=404, detail="Routine not found")

    # Convertir el ID de la rutina a cadena para comparar
    routine_id_str = str(routine["_id"])
    if routine_id_str not in client.get("idroutines", []):
        raise HTTPException(status_code=404, detail="Routine not associated with client")

    # Eliminar la rutina
    result = collection_routines.delete_one({"_id": ObjectId(routine_id)})
    if result.deleted_count == 1:
        collection_clients.update_one(
            {"_id": ObjectId(client_id)},
            {"$pull": {"idroutines": routine_id_str}}  # Pasar el ID de la rutina como cadena
        )
        return {"message": "Routine deleted successfully"}
    else:
        raise HTTPException(status_code=500, detail="Failed to delete routine")
