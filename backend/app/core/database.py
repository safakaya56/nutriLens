from motor.motor_asyncio import AsyncIOMotorClient
from app.core.config import settings

class Database:
    client: AsyncIOMotorClient = None
    db = None

db_manager = Database()

async def connect_to_mongo():
    db_manager.client = AsyncIOMotorClient(settings.MONGODB_URI)
    db_manager.db = db_manager.client.get_default_database("nutrilens_db")
    print("SUCCESS: Connected to MongoDB Atlas successfully!")

async def close_mongo_connection():
    if db_manager.client:
        db_manager.client.close()
        print("INFO: MongoDB connection closed.")

def get_database():
    return db_manager.db
