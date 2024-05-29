from http.client import HTTPException
from fastapi import APIRouter
from models.machine import Machine
from models.exercise import Exercise
from models.client import Client
from models.routine import Routine
from models.user import User
from bson.objectid import ObjectId
from models.exercise_preset import ExercisePreset
from conifg.database import collection_clients, collection_routines, collection_exercises, collection_machines, collection_exercises_preset, collection_users
from schema.schemas import list_clients, list_exercises, list_machines, serial_client, list_routines, serial_exercises, serial_machine, serial_exercise_preset, list_exercise_presets, serial_user
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

router = APIRouter()

def hash(password: str):
    hashed = pwd_context.hash(password)
    return hashed
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

    routine_id_str = str(routine["_id"])
    if routine_id_str not in client.get("idroutines", []):
        raise HTTPException(status_code=404, detail="Routine not associated with client")

    result = collection_routines.delete_one({"_id": ObjectId(routine_id)})
    if result.deleted_count == 1:
        collection_clients.update_one(
            {"_id": ObjectId(client_id)},
            {"$pull": {"idroutines": routine_id_str}}  
        )
        return {"message": "Routine deleted successfully"}
    else:
        raise HTTPException(status_code=500, detail="Failed to delete routine")
    
@router.get("/exercises/")
async def get_exercises():
    exercises = list_exercises(collection_exercises.find())
    return exercises

@router.get("/exercises/{id}")
async def find_exercise(id: str):
    exercise = collection_exercises.find_one({"_id": ObjectId(id)})
    if exercise is None:
        raise HTTPException(status_code=404, detail="Exercise not found")
    return serial_exercises(exercise)

@router.put("/exercises/{id}")
async def update_exercise(id: str, exercise: Exercise):
    collection_exercises.find_one_and_update({"_id": ObjectId(id)}, {"$set": exercise.model_dump()})
    return exercise

@router.delete("/exercises/{id}")
async def delete_exercise(id: str):
    collection_exercises.find_one_and_delete({"_id": ObjectId(id)})
    return {"message": "exercise deleted successfully!"}

@router.post("/machines/")
async def create_machine(machine: Machine):
    collection_machines.insert_one(machine.model_dump())
    return machine

@router.get("/machines/")
async def get_machines():
    machines = list_machines(collection_machines.find())
    return machines

@router.get("/machines/{id}")
async def find_machine(id: str):
    machine = collection_machines.find_one({"_id": ObjectId(id)})
    if machine is None:
        raise HTTPException(status_code=404, detail="Machine not found")
    return serial_machine(machine)

@router.delete("/machines/{id}")
async def delete_machine(id: str):
    collection_machines.find_one_and_delete({"_id": ObjectId(id)})
    return {"message": "machine deleted successfully!"}

@router.post("/exercises_preset/")
async def create_exercise_preset(exercise: ExercisePreset):
    collection_exercises_preset.insert_one(exercise.model_dump())
    return exercise

@router.get("/exercises_preset/")
async def get_exercises_preset():
    exercises = list_exercise_presets(collection_exercises_preset.find())
    return exercises

@router.get("/exercises_preset/{id}")
async def find_exercise_preset(id: str):
    exercise = collection_exercises_preset.find_one({"_id": ObjectId(id)})
    if exercise is None:
        raise HTTPException(status_code=404, detail="Exercise not found")
    return serial_exercise_preset(exercise)

@router.delete("/exercises_preset/{id}")
async def delete_exercise_preset(id: str):
    collection_exercises_preset.find_one_and_delete({"_id": ObjectId(id)})
    return {"message": "exercise deleted successfully!"}

@router.post("/clients/{client_id}/routines/{routine_id}/exercise/")
async def add_exercise_to_routine(client_id: str, routine_id: str, exercise_preset_id: str, sets: int, reps: int, weight: float, machine_id: str):
    selected_preset = collection_exercises_preset.find_one({"_id": ObjectId(exercise_preset_id)})
    selected_machine = collection_machines.find_one({"_id": ObjectId(machine_id)})
    if not selected_preset:
        raise HTTPException(status_code=404, detail="Exercise preset not found")
    completed_exercise = Exercise(
        id=selected_preset["_id"],
        name=selected_preset["name"],
        sets=sets,
        reps=reps,
        weight=weight,
        machine=selected_machine["name"] if selected_machine else None
    )
    routine = collection_routines.find_one({"_id": ObjectId(routine_id)})
    if routine is None:
        raise HTTPException(status_code=404, detail="Routine not found")
    collection_routines.update_one(
        {"_id": ObjectId(routine_id)},
        {"$addToSet": {"exercises": completed_exercise.model_dump()}}
    )
    return completed_exercise

@router.post("/user")
async def create_user(new_id: str, new_name: str, new_password: str, new_rut: str):
    created = collection_users.find_one({"id": new_id})
    if created is None:
        hashed_password = hash(new_password)
        user = User(id = new_id, name = new_name, password = hashed_password, rut = new_rut)
        collection_users.insert_one(dict(user))
    else:
        raise HTTPException(status_code=401, detail = "User already created")
    return user

@router.get("/user/login")
async def login(id: str, password:str):
    user = collection_users.find_one({"id":id})
    if user is not None:
        if pwd_context.verify(password, user["password"]):
            return serial_user(user)
        else:
            raise HTTPException(status_code=404,detail="Incorrect password")
    else:
        raise HTTPException(status_code=404, detail="User not found")