from pydantic import BaseModel

class Exercise(BaseModel):
    name: str
    sets: int
    reps: int
    weight: int
