from pydantic import BaseModel
from typing import Optional

class Client(BaseModel):
    name: str
    rut: str
    health: bool
    email: str
    phone: str
    idroutines: Optional[list]
    idDraft: Optional[str]

