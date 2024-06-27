from typing import Optional
from fastapi import APIRouter, Body, HTTPException
from models.user import User
from models.draft import Draft
from models.lap import Lap
from models.machine import Machine
from models.exercise import Exercise
from models.client import Client
from models.routine import Routine
from models.trainer import Trainer
from bson.objectid import ObjectId
from models.exercise_preset import ExercisePreset
from conifg.database import collection_clients, collection_routines, collection_exercises, collection_machines, collection_exercises_preset, collection_laps, collection_drafts,collection_users, collection_trainers
from schema.schemas import list_clients, list_exercises, list_laps, list_machines, serial_client, list_routines, serial_exercises, serial_machine, serial_exercise_preset, list_exercise_presets, serial_lap, list_drafts, serial_draft, serial_user, list_trainers, serial_trainer
from passlib.context import CryptContext

router = APIRouter()


# CLIENTS #
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
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
    client_dict = client.model_dump(exclude_unset=True)
    if "idroutines" in client_dict and not client_dict["idroutines"]:
        del client_dict["idroutines"] 
    collection_clients.find_one_and_update({"_id": ObjectId(id)}, {"$set": client_dict})
    return client

@router.delete("/{id}")
async def delete_client(id: str):
    collection_clients.find_one_and_delete({"_id": ObjectId(id)})
    return {"message": "client deleted successfully!"}

@router.delete("/")
async def delete_clients():
    collection_clients.delete_many({})
    return {"message": "clients deleted successfully!"}

# ROUTINES #

@router.post("/clients/{client_id}/routines/")
async def create_routine_for_client(client_id: str, routine: Routine, draft_id: str = Body(...)):
    draft = collection_drafts.find_one({"_id": ObjectId(draft_id)})
    if not draft:
        raise HTTPException(status_code=404, detail="Draft not found")
    routine.laps = draft.get("laps", [])
    inserted_routine = collection_routines.insert_one(routine.model_dump())
    routine_id = str(inserted_routine.inserted_id)
    collection_clients.update_one(
        {"_id": ObjectId(client_id)},
        {
            "$addToSet": {"idroutines": routine_id},
            "$set": {"idDraft": ""}
        }
    )
    collection_drafts.find_one_and_delete(
        {"_id": ObjectId(draft_id)}   
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
    
@router.delete("/routines/")
async def delete_routines():
    collection_clients.update_many({}, {"$set": {"idroutines": []}})
    collection_routines.delete_many({})
    return {"message": "routines deleted successfully!"}
    
# EXERCISES #

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

@router.delete("/exercises/{id}/lap/{lap_id}")
async def delete_exercise_from_lap(id: str, lap_id: str):
    try:
        lap = collection_laps.find_one({"_id": ObjectId(lap_id)})
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Invalid lap_id: {e}")

    if not lap:
        raise HTTPException(status_code=404, detail="Lap not found")

    result = collection_laps.update_one(
        {"_id": ObjectId(lap_id)},
        {"$pull": {"exercises": id}}
    )

    if result.modified_count == 1:
        collection_exercises.delete_one({"_id": ObjectId(id)})
        return {"message": "Exercise deleted successfully from lap"}
    else:
        raise HTTPException(status_code=500, detail="Failed to delete exercise from lap")

# MACHINES #

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

@router.put("/machines/{id}")
async def update_machine(id: str, machine: Machine):
    collection_machines.find_one_and_update({"_id": ObjectId(id)}, {"$set": machine.model_dump()})
    return machine

# EXERCISES PRESET #

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

# LAPS #

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

@router.get("/laps/{draft_id}/drafts")
async def get_draft_laps(draft_id: str):
    draft = collection_drafts.find_one({"_id": ObjectId(draft_id)})
    if draft is None:
        raise HTTPException(status_code=404, detail="Draft not found")
    draft_laps_ids = draft.get("laps", [])
    draft_laps = []
    for lap_id in draft_laps_ids:
        lap = collection_laps.find_one({"_id": ObjectId(lap_id)})
        if lap:
            draft_laps.append(lap)
    return list_laps(draft_laps)

@router.post("/draft/{draft_id}/lap/")
async def create_lap_for_draft(draft_id: str, lap: Lap):
    inserted_lap = collection_laps.insert_one(lap.model_dump())
    lap_id = str(inserted_lap.inserted_id)
    draft = collection_drafts.find_one({"_id": ObjectId(draft_id)})
    if draft is None:
        raise HTTPException(status_code=404, detail="Draft not found")
    collection_drafts.update_one(
        {"_id": ObjectId(draft_id)},
        {"$addToSet": {"laps": lap_id}}
    )
    return lap_id

@router.put("/lap/{lap_id}/sets/")
async def update_lap_sets(lap_id: str, sets: int = Body(...)):
    collection_laps.find_one_and_update({"_id": ObjectId(lap_id)}, {"$set": {"sets": sets}})
    return sets

@router.post("/lap/{lap_id}/exercise/")
async def add_exercise_to_lap(
    lap_id: str,
    exercise_preset_id: str = Body(...),
    duration: int = Body(default=0),
    reps: int = Body(default=0),
    weight: float = Body(default=0),
    machine_id: Optional[str] = Body(default=None)
):
    try:
        selected_preset = collection_exercises_preset.find_one({"_id": ObjectId(exercise_preset_id)})
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Invalid exercise_preset_id: {e}")

    if not selected_preset:
        raise HTTPException(status_code=404, detail="Exercise preset not found")

    selected_machine = None
    if machine_id:
        try:
            selected_machine = collection_machines.find_one({"_id": ObjectId(machine_id)})
        except Exception as e:
            raise HTTPException(status_code=400, detail=f"Invalid machine_id: {e}")

    try:
        lap = collection_laps.find_one({"_id": ObjectId(lap_id)})
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Invalid lap_id: {e}")

    if not lap:
        raise HTTPException(status_code=404, detail="Lap not found")

    new_exercise = {
        "preset": str(selected_preset["_id"]),
        "name": selected_preset["name"],
        "duration": duration,
        "reps": reps,
        "weight": weight,
        "machine": selected_machine["name"] if selected_machine else None
    }

    exercise_result = collection_exercises.insert_one(new_exercise)
    exercise_id = str(exercise_result.inserted_id)
    
    result = collection_laps.update_one(
        {"_id": ObjectId(lap_id)},
        {"$addToSet": {"exercises": exercise_id}}
    )

    if result.modified_count == 0:
        raise HTTPException(status_code=500, detail="Failed to add exercise to lap")
    
    return {"exercise_id": exercise_id, "exercise": serial_exercises(new_exercise)}

@router.get("/laps/exercises/{lap_id}")
async def get_lap_exercises(lap_id: str):
    try:
        lap = collection_laps.find_one({"_id": ObjectId(lap_id)})
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Invalid lap_id: {e}")

    if not lap:
        raise HTTPException(status_code=404, detail="Lap not found")

    exercise_ids = lap.get("exercises", [])
    exercises = []

    for exercise_id in exercise_ids:
        try:
            exercise = collection_exercises.find_one({"_id": ObjectId(exercise_id)})
            if exercise:
                exercises.append(exercise)
        except Exception as e:
            raise HTTPException(status_code=400, detail=f"Invalid exercise_id: {e}")

    return list_exercises(exercises)

@router.get("/laps/{lap_id}")
async def get_lap(lap_id: str):
    lap = collection_laps.find_one({"_id": ObjectId(lap_id)})
    if not lap:
        raise HTTPException(status_code=404, detail="Lap not found")
    return serial_lap(lap)

@router.delete("/laps/{lap_id}/draft/{draft_id}/")
def delete_lap_from_draft(lap_id: str, draft_id: str):
    draft = collection_drafts.find_one({"_id": ObjectId(draft_id)})
    if not draft:
        raise HTTPException(status_code=404, detail="Draft not found")
    result = collection_drafts.update_one(
        {"_id": ObjectId(draft_id)},
        {"$pull": {"laps": lap_id}}
    )
    if result.modified_count == 1:
        collection_laps.delete_one({"_id": ObjectId(lap_id)})
        return {"message": "Lap deleted successfully from draft"}
    else:
        raise HTTPException(status_code=500, detail="Failed to delete lap from draft")

@router.delete("/laps/")
async def delete_laps():
    try:
        laps_to_delete = collection_laps.find({})
        for lap in laps_to_delete:
            for exercise_id in lap.get("exercises", []):
                collection_exercises.delete_one({"_id": ObjectId(exercise_id)})
        collection_routines.update_many({}, {"$set": {"laps": []}})
        result = collection_laps.delete_many({})
        if result.deleted_count > 0:
            return {"message": "Laps and associated exercises deleted successfully!"}
        else:
            raise HTTPException(status_code=404, detail="No laps found to delete")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Server error: {str(e)}")

# DRAFTS #

@router.post("/drafts/client/{client_id}")
async def create_draft(draft: Draft, client_id: str):
    client = collection_clients.find_one({"_id": ObjectId(client_id)})
    if not client:
        raise HTTPException(status_code=404, detail="Client not found")
    if client.get("idDraft"):
        raise HTTPException(status_code=400, detail="Client already has a draft")
    inserted_draft = collection_drafts.insert_one(draft.model_dump())
    draft_id = str(inserted_draft.inserted_id)
    collection_clients.update_one(
        {"_id": ObjectId(client_id)},
        {"$set": {"idDraft": draft_id}}
    )
    return draft_id

@router.get("/drafts/client/{client_id}")
async def get_client_draft(client_id: str):
    client = collection_clients.find_one({"_id": ObjectId(client_id)})
    if not client:
        raise HTTPException(status_code=404, detail="Client not found")
    draft_id = client.get("idDraft")
    if not draft_id:
        raise HTTPException(status_code=404, detail="Draft not found")
    draft = collection_drafts.find_one({"_id": ObjectId(draft_id)})
    if not draft:
        raise HTTPException(status_code=404, detail="Draft not found")
    return serial_draft(draft)

@router.get("/drafts/")
async def get_drafts():
    drafts = list_drafts(collection_drafts.find())
    return drafts

@router.delete("/drafts/{id}")
async def delete_draft(id: str):
    collection_drafts.find_one_and_delete({"_id": ObjectId(id)})
    collection_clients.update_many({}, {"$set": {"idDraft": ""}})
    return {"message": "draft deleted successfully!"}

@router.delete("/drafts/")  
async def delete_drafts():
    collection_clients.update_many({}, {"$set": {"idDraft": ""}})
    collection_drafts.delete_many({})
    return {"message": "drafts deleted successfully!"}

# USERS #

@router.post("/user")
async def create_user(new_id: str, new_name: str, new_password: str, new_rut: str, new_type: bool):
    if " " in new_id or " " in new_password:
        raise HTTPException(status_code=400, detail="Username or password cannot contain spaces")
    created = collection_users.find_one({"id": new_id})
    if created is None:
        hashed_password = hash(new_password)
        user = User(id=new_id, name=new_name, password=hashed_password, rut=new_rut, admin=new_type)
        collection_users.insert_one(user.dict())
    else:
        raise HTTPException(status_code=401, detail="Username already in use")
    return user

@router.get("/user/login")
async def login(id: str, password: str):
    user = collection_users.find_one({"id": id})
    if user is not None:
        if pwd_context.verify(password, user["password"]):
            return serial_user(user)
        else:
            raise HTTPException(status_code=401, detail="Invalid password")
    else:
        raise HTTPException(status_code=401, detail="User not found")
    
# TRAINERS #

@router.post("/trainers/")
async def create_trainer(trainer: Trainer):
    collection_trainers.insert_one(trainer.model_dump())
    return trainer

@router.get("/trainers/")
async def get_trainers():
    trainers = list_trainers(collection_trainers.find())
    return trainers

@router.get("/trainers/{id}")
async def find_trainer(id: str):
    trainer = collection_trainers.find_one({"_id": ObjectId(id)})
    if trainer is None:
        raise HTTPException(status_code=404, detail="Trainer not found")
    return serial_trainer(trainer)

@router.delete("/trainers/{id}")
async def delete_trainer(id: str):
    collection_trainers.find_one_and_delete({"_id": ObjectId(id)})
    return {"message": "trainer deleted successfully!"}

@router.put("/trainers/{id}")
async def update_trainer(id: str, trainer: Trainer):
    collection_trainers.find_one_and_update({"_id": ObjectId(id)}, {"$set": trainer.model_dump()})
    return trainer

@router.put("/trainers/{trainer_id}/clients/{client_id}")
async def add_client_to_trainer(trainer_id: str, client_id: str):
    client = collection_clients.find_one({"_id": ObjectId(client_id)})
    if not client:
        raise HTTPException(status_code=404, detail="Client not found")
    result = collection_trainers.update_one(
        {"_id": ObjectId(trainer_id)},
        {"$addToSet": {"clients": client_id}}
    )
    if result.modified_count == 0:
        raise HTTPException(status_code=500, detail="Failed to add client to trainer")
    return {"message": "Client added to trainer successfully"}
