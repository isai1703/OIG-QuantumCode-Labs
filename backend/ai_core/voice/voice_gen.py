import os

def text_to_speech(text: str) -> str:
    """
    Generación de voz – placeholder.
    Después se conecta a un TTS real (Bark, Coqui, OpenAI TTS, etc.)
    """
    out_path = f"/tmp/voice_{abs(hash(text))}.wav"

    # Crea un archivo vacío de ejemplo para simular salida
    with open(out_path, "wb") as f:
        f.write(b"")

    return out_path
