from pydantic import BaseModel
from typing import List, Optional

class Client(BaseModel):
    name: str
    rut: str
    health: bool
    email: str
    phone: str
    idroutines: Optional[List[str]] = None 
    idDraft: Optional[str]

