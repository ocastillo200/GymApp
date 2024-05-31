from typing import Optional
from pydantic import BaseModel

class Lap(BaseModel):
    exercises: Optional[list]
    sets: int