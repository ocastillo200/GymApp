from http.client import HTTPException
from typing import Optional
from fastapi import APIRouter, Body
from models.lap import Lap
from models.machine import Machine
from models.exercise import Exercise
from models.client import Client
from models.routine import Routine
from bson.objectid import ObjectId
from models.exercise_preset import ExercisePreset
from conifg.database import collection_clients, collection_routines, collection_exercises, collection_machines, collection_exercises_preset, collection_laps
from schema.schemas import list_clients, list_exercises, list_laps, list_machines, serial_client, list_routines, serial_exercises, serial_machine, serial_exercise_preset, list_exercise_presets, serial_lap
router = APIRouter()

#CLIENTS#

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

@router.delete("/")
async def delete_clients():
    collection_clients.delete_many({})
    return {"message": "clients deleted successfully!"}

#ROUTINES#

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
    
#EXERCISES#

@router.post("/exercises")
async def create_exercise(exercise: Exercise):
    collection_exercises.insert_one(exercise.model_dump())
    return exercise

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

#MACHINES#

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

@router.delete("/machines/")
async def delete_machines():
    collection_machines.delete_many({})
    return {"message": "machines deleted successfully!"}

@router.delete("/machines/{id}")
async def delete_machine(id: str):
    collection_machines.find_one_and_delete({"_id": ObjectId(id)})
    return {"message": "machine deleted successfully!"}

#EXERCISES PRESET#

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

#LAPS#

@router.get("/laps/routines/{routine_id}")
async def get_routine_laps(routine_id: str):
    routine = collection_routines.find_one({"_id": ObjectId(routine_id)})
    if routine is None:
        raise HTTPException(status_code=404, detail="Routine not found")
    routine_laps_ids = routine.get("laps", [])
    routine_laps = []
    for lap_id in routine_laps_ids:
        lap = collection_laps.find_one({"_id": ObjectId(lap_id)})
        if lap:
            routine_laps.append(lap)
    return list_laps(routine_laps)

@router.post("/routines/{routine_id}/lap/")
async def create_lap_for_routine(routine_id: str, lap: Lap):
    inserted_lap = collection_laps.insert_one(lap.model_dump())
    lap_id = str(inserted_lap.inserted_id)
    routine = collection_routines.find_one({"_id": ObjectId(routine_id)})
    if routine is None:
        raise HTTPException(status_code=404, detail="Routine not found")
    collection_routines.update_one(
        {"_id": ObjectId(routine_id)},
        {"$addToSet": {"laps": lap_id}}
    )
    return lap

@router.post("/lap/{lap_id}/exercise/")
async def add_exercise_to_lap(
    lap_id: str,
    exercise_preset_id: str,
    duration: int,
    reps: int,
    weight: float,
    machine_id: Optional[str] = Body(default=None)
):
    selected_preset = collection_exercises_preset.find_one({"_id": ObjectId(exercise_preset_id)})
    if not selected_preset:
        raise HTTPException(status_code=404, detail="Exercise preset not found")
    selected_machine = None
    if machine_id:
        selected_machine = collection_machines.find_one({"_id": ObjectId(machine_id)})
    
    lap = collection_laps.find_one({"_id": ObjectId(lap_id)})
    if not lap:
        raise HTTPException(status_code=404, detail="Lap not found")
    
    completed_exercise = {
        "preset_id": str(selected_preset["_id"]),
        "name": selected_preset["name"],
        "duration": duration,
        "reps": reps,
        "weight": weight,
        "machine": selected_machine["name"] if selected_machine else None
    }
    
    result = collection_laps.update_one(
        {"_id": ObjectId(lap_id)},
        {"$addToSet": {"exercises": completed_exercise}}
    )
    
    if result.modified_count == 0:
        raise HTTPException(status_code=500, detail="Failed to add exercise to lap")
    
    return completed_exercise

@router.get("/laps/{lap_id}")
async def get_lap(lap_id: str):
    lap = collection_laps.find_one({"_id": ObjectId(lap_id)})
    if not lap:
        raise HTTPException(status_code=404, detail="Lap not found")
    return serial_lap(lap)

@router.delete("/laps/{lap_id}/routine/{routine_id}/")
async def delete_lap(lap_id: str, routine_id: str):
    try:
        lap_object_id = ObjectId(lap_id)
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Invalid lap_id: {str(e)}")
    
    try:
        routine_object_id = ObjectId(routine_id)
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Invalid routine_id: {str(e)}")

    try:
        result = collection_laps.delete_one({"_id": lap_object_id})
        if result.deleted_count == 1:
            routine_result = collection_routines.update_one(
                {"_id": routine_object_id},
                {"$pull": {"laps": lap_object_id}}
            )
            if routine_result.modified_count == 1:
                return {"message": "Lap deleted successfully from collection and routine"}
            else:
                raise HTTPException(status_code=500, detail="Failed to delete lap from routine")
        else:
            raise HTTPException(status_code=500, detail="Failed to delete lap")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Server error: {str(e)}")

@router.delete("/laps/")
async def delete_laps():
    collection_routines.update_many({}, {"$set": {"laps": []}})
    collection_laps.delete_many({})
    return {"message": "laps deleted successfully!"}


