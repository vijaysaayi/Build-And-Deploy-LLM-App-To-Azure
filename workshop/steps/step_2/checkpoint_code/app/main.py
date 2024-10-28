from fastapi import FastAPI
app = FastAPI()

@app.get("/")
async def root():
    return "Please browse to /chat with a message to chat with the AI."


@app.get("/chat")
async def chat(message: str):
    return message
