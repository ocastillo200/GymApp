from pydantic import BaseModel
from typing import List, Optional

class Client(BaseModel):
    image: Optional[str] = None  # Base64 image
    name: str
    rut: str
    health: bool
    email: str
    phone: str
    idroutines: Optional[List[str]] = None 
    idDraft: Optional[str]

