def serial_client(client) -> dict:
    return {
        "id": str(client["_id"]),
        "name": client["name"],
        "rut": client["rut"],
        "payment": client["payment"],
        "email": client["email"],
        "phone": client["phone"],
        "idroutines": client["idroutines"]
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
        preset_data["machine_ids"] = exercise["machine_ids"]
    return preset_data

def list_exercise_presets(exercises) -> list:
    return [serial_exercise_preset(exercise) for exercise in exercises]

def serial_lap(lap) -> dict:
    return { 
        "id": str(lap["_id"]),
        "exercises": lap["exercises"],
        "series": lap["series"],
    }
def list_laps(laps) -> list:
    return [serial_lap(lap) for lap in laps]