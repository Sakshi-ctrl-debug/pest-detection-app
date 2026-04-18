from fastapi import FastAPI, File, UploadFile
from fastapi.responses import JSONResponse
from PIL import Image
import numpy as np
import tensorflow as tf
import io
import json
from pest_info import PEST_INFO

app = FastAPI()

# Load model once at startup
print("🔄 Loading TensorFlow model...")
model = tf.keras.models.load_model("pest_model.h5")
print("✅ Model loaded successfully")

# Load class names
with open("class_names.json") as f:
    classes = json.load(f)

print(f"✅ Loaded {len(classes)} pest classes")
print("🚀 Backend is ready for inference!")
print("")

@app.get("/health")
async def health_check():
    """Health check endpoint to verify backend is running"""
    return {
        "status": "healthy",
        "message": "Backend is running and ready for pest detection",
        "model": "pest_model.h5",
        "classes": len(classes)
    }

@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "name": "Pest Detection Backend",
        "version": "1.0",
        "endpoints": {
            "health": "/health",
            "detect": "/detect-pest",
            "docs": "/docs"
        }
    }

def preprocess(image):
    # Optimized preprocessing
    image = image.resize((224, 224), Image.Resampling.LANCZOS)  # Better quality resize
    img = np.array(image, dtype=np.float32) / 255.0  # Use float32 for better precision
    img = np.expand_dims(img, axis=0)
    return img

@app.post("/detect-pest")
async def detect_pest(file: UploadFile = File(...)):
    try:
        # Read and process image
        image = Image.open(io.BytesIO(await file.read())).convert("RGB")
        img = preprocess(image)

        # Run inference
        preds = model.predict(img, verbose=0)[0]  # Disable verbose output
        index = int(np.argmax(preds))
        confidence = float(preds[index] * 100)

        pest = classes[index]

        return {
            "pest": pest,
            "confidence": round(confidence, 2),
            "info": PEST_INFO.get(pest, "Info not available")
        }
    except Exception as e:
        return {"error": f"Processing failed: {str(e)}"}
