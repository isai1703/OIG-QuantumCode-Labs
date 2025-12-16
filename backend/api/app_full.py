from fastapi import FastAPI
from pydantic import BaseModel

from ai_core.image.image_gen import generate_image
from ai_core.video.video_gen import generate_video
from ai_core.voice.voice_gen import text_to_speech
from ai_core.text.text_gen import generate_text

app = FastAPI(title="OIG QuantumCode Labs - Full AI API")

class PromptReq(BaseModel):
    prompt: str
    duration: int = 4
    style: str = "cinematic"

@app.get("/")
async def root():
    return {"status": "ok", "service": "OIG QuantumCode Labs AI"}

@app.post("/chat")
async def chat(req: PromptReq):
    out = generate_text(req.prompt)
    return {"status": "ok", "result": out}

@app.post("/image")
async def image(req: PromptReq):
    out = generate_image(req.prompt)
    return {"status": "ok", "url": out.get("url", out)}

@app.post("/video")
async def video(req: PromptReq):
    out = generate_video(req.prompt, req.duration, req.style)
    return out

@app.post("/voice")
async def voice(req: PromptReq):
    out = text_to_speech(req.prompt)
    return {"status": "ok", "path": out}
