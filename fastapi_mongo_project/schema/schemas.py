import base64

def serial_client(client) -> dict:
    image = client.get("image", None)
    
    # Verifica si la imagen ya está en formato base64
    if image and isinstance(image, str):
        return {
            "image": image,  # Si ya es un string (base64), lo devuelve directamente
            "id": str(client["_id"]),
            "name": client["name"],
            "rut": client["rut"],
            "health": client["health"],
            "email": client["email"],
            "phone": client["phone"],
            "idroutines": client["idroutines"],
            "idDraft": client["idDraft"]
        }
    elif image and isinstance(image, bytes):
        # Si es un bytes (normalmente leído desde la base de datos)
        return {
            "image": base64.b64encode(image).decode("utf-8"),
            "id": str(client["_id"]),
            "name": client["name"],
            "rut": client["rut"],
            "health": client["health"],
            "email": client["email"],
            "phone": client["phone"],
            "idroutines": client["idroutines"],
            "idDraft": client["idDraft"]
        }
    else:
        # Si la imagen no está presente o no es válida
        return {
            "image": None,
            "id": str(client["_id"]),
            "name": client["name"],
            "rut": client["rut"],
            "health": client["health"],
            "email": client["email"],
            "phone": client["phone"],
            "idroutines": client["idroutines"],
            "idDraft": client["idDraft"]
        }
def list_clients(clients) -> list:
    return [serial_client(client) for client in clients]

def serial_routine(routine) -> dict:
    return {
        "id": str(routine["_id"]),
        "date": routine["date"],
        "comment": routine["comment"],
        "trainer": routine["trainer"],
        "laps": routine["laps"],
    }
def list_routines(routines) -> list:  
    return [serial_routine(routine) for routine in routines]

def serial_exercises(exercise) -> dict:    
    return {
        "id": str(exercise["_id"]),
        "preset": exercise["preset"], 
        "name": exercise["name"],
        "reps": exercise["reps"],
        "duration": exercise["duration"],
        "weight": exercise["weight"],
        "machine": exercise["machine"],
    }

def list_exercises(exercises) -> list: 
    return [serial_exercises(exercise) for exercise in exercises]

def serial_machine(machine) -> dict:    
    return {
        "id": str(machine["_id"]),
        "name": machine["name"],
        "quantity": machine["quantity"],
        "available": machine["available"],
    }
def list_machines(machines) -> list:
    return [serial_machine(machine) for machine in machines]

def serial_exercise_preset(exercise) -> dict:
    preset_data = {
        "id": str(exercise["_id"]),
        "name": exercise["name"],
    }
    if "machine_ids" in exercise:
        preset_data["machine_ids"] = [str(id) for id in exercise["machine_ids"]]
    return preset_data

def list_exercise_presets(exercises) -> list:
    return [serial_exercise_preset(exercise) for exercise in exercises]

def serial_lap(lap) -> dict:
    return { 
        "id": str(lap["_id"]),
        "exercises": lap["exercises"],
        "sets": lap["sets"],
    }
def list_laps(laps) -> list:
    return [serial_lap(lap) for lap in laps]

def serial_draft(draft) -> dict:
    return {
        "id": str(draft["_id"]),
        "laps": draft["laps"],
    }
def list_drafts(drafts) -> list:
    return [serial_draft(draft) for draft in drafts]
def serial_user(user)->dict:
    return{
        "id": user["id"],
        "name": user["name"],
        "rut": user["rut"],
        "password": user["password"],
        "admin":user["admin"]
    }

def serial_trainer(trainer) -> dict:    
    return {
        "id": str(trainer["_id"]),
        "name": trainer["name"],
        "clients": trainer["clients"]
    }

def list_trainers(trainers) -> list:
    return [serial_trainer(trainer) for trainer in trainers]
