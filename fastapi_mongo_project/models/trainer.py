from pydantic import BaseModel
from typing import List, Optional

class Trainer(BaseModel):
    name: str
    clients: Optional[list]