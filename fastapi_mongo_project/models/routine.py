from pydantic import BaseModel

class Routine(BaseModel):
    date : str
    comment: str
    exercises: list


    

