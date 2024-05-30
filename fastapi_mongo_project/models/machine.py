from pydantic import BaseModel

class Machine(BaseModel):
    name: str
    quantity: int
    available: int

    
