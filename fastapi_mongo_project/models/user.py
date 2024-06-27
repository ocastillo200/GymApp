from pydantic import BaseModel

class User(BaseModel):
    username: str
    name: str
    rut: str
    password: str
    admin: bool
