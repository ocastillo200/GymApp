from pydantic import BaseModel
from typing import Optional

class Routine(BaseModel):
    date : Optional[str]
    comment: str
    exercises: Optional[list]



    

