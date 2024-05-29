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
        "exercises": routine["exercises"],
        "trainer": routine["trainer"]
    }
def list_routines(routines) -> list:  
    return [serial_routine(routine) for routine in routines]

def serial_exercises(exercise) -> dict:    
    return {
        "id": str(exercise["_id"]),
        "name": exercise["name"],
        "sets": exercise["sets"],
        "reps": exercise["reps"],
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
    return {
        "id": str(exercise["_id"]),
        "name": exercise["name"],
        "machine_ids": exercise["machine_ids"],
    }

def list_exercise_presets(exercises) -> list:
    return [serial_exercise_preset(exercise) for exercise in exercises]