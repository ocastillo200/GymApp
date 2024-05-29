from pydantic import BaseModel
from typing import Optional

class Machine(BaseModel):
    name: str
    quantity: int
    available: int

    
