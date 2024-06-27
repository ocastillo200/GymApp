from pydantic import BaseModel
from typing import List, Optional

class Trainer(BaseModel):
    name: str
    rut: str
    clients: Optional[List] = []