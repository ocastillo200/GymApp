from pydantic import BaseModel

class Client(BaseModel):
    name: str
    rut: str
    payment: bool
    email: str
    phone: str
    idroutines: list

