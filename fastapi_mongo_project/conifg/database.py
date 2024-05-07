from pymongo import MongoClient

connection = MongoClient("mongodb+srv://admin:GGIJSXEuC6ktz6FU@cluster0.zkh3j9j.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0", tls=True, tlsAllowInvalidCertificates=True)

db = connection.gym_app  
collection_clients = db["clients"]
collection_routines = db["routines"]
collection_exercises = db["exercises"]
collection_users = db["users"]
collection_sesions = db["sesions"]



