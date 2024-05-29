from typing import Optional
from pydantic import BaseModel

class ExercisePreset(BaseModel):
    name: str
    machine_ids: Optional[list]