from fastapi import FastAPI, File, UploadFile
from PIL import Image
import numpy as np
import tensorflow as tf
import io
from pest_info import PEST_INFO

app = FastAPI()

model = tf.keras.models.load_model("pest_model.h5")
# classes = ["aphids", "whiteflies", "caterpillar", "beetle"]
classes = ['aphids', 'beetle', 'caterpillar', 'whiteflies']

def preprocess(image):
    image = image.resize((224, 224))
    img = np.array(image) / 255.0
    img = np.expand_dims(img, axis=0)
    return img

@app.post("/detect-pest")
async def detect_pest(file: UploadFile = File(...)):
    image = Image.open(io.BytesIO(await file.read())).convert("RGB")
    img = preprocess(image)

    preds = model.predict(img)[0]
    index = int(np.argmax(preds))
    confidence = float(preds[index] * 100)

    pest = classes[index]

    return {
        "pest": pest,
        "confidence": round(confidence, 2),
        "info": PEST_INFO[pest]
    }
