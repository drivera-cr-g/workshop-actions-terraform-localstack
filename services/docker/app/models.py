from pydantic import BaseModel

# Simple item to be saved to DynamoDB table


class Item(BaseModel):
    MainIndexKey: str
    data: str
