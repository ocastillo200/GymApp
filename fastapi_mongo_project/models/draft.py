from pydantic import BaseModel
from typing import Optional

class Draft(BaseModel):
    laps: Optional[list]


