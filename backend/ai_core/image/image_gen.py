def generate_image(prompt: str) -> dict:
    """
    Generador de imágenes – placeholder.
    Luego lo conectamos con un modelo real (Stable Diffusion, Flux, etc.)
    """
    fake_url = f"https://dummyimage.com/1024x1024/000/fff&text={prompt.replace(' ', '+')}"
    return {"url": fake_url}
