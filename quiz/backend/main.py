import os
import shutil
import tempfile
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from PIL import Image
import pytesseract

# Try to find Tesseract on Windows if it's not in PATH
if os.name == 'nt':
    common_tesseract_paths = [
        r'C:\Program Files\Tesseract-OCR\tesseract.exe',
        r'C:\Users\{}\AppData\Local\Tesseract-OCR\tesseract.exe'.format(os.getenv('USERNAME')),
    ]
    for path in common_tesseract_paths:
        if os.path.exists(path):
            pytesseract.pytesseract.tesseract_cmd = path
            break

from pdf2image import convert_from_path
from pydantic import BaseModel
from typing import List, Union, Dict
from transformers import pipeline
import torch

class MCQRequest(BaseModel):
    extracted_text: str

class TranslationRequest(BaseModel):
    text: Union[str, List[str]]
    target_language: str = "tel"

app = FastAPI(title="AI Quiz OCR Backend")

# Lazy translation pipeline
_translator = None
_translation_cache: Dict[str, str] = {}

def get_translator():
    global _translator
    if _translator is None:
        print("Loading translation model (facebook/nllb-200-distilled-600M)...")
        _translator = pipeline(
            "translation",
            model="facebook/nllb-200-distilled-600M",
            device=0 if torch.cuda.is_available() else -1
        )
    return _translator

# Enable CORS since Flutter web/mobile might hit it
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def root():
    return {"status": "ok", "message": "OCR Backend is running"}

@app.post("/extract-text")
async def extract_text(file: UploadFile = File(...)):
    """
    Accepts an uploaded image or PDF file, runs Tesseract OCR,
    and returns the extracted text.
    """
    if not file.filename:
        raise HTTPException(status_code=400, detail="No file uploaded")
    
    ext = os.path.splitext(file.filename)[1].lower()
    allowed_extensions = {".png", ".jpg", ".jpeg", ".pdf"}
    
    if ext not in allowed_extensions:
        raise HTTPException(status_code=400, detail="Unsupported file format")

    try:
        # Save uploaded file to a temporary location
        with tempfile.NamedTemporaryFile(delete=False, suffix=ext) as temp_file:
            shutil.copyfileobj(file.file, temp_file)
            temp_file_path = temp_file.name

        extracted_text = ""

        try:
            if ext == ".pdf":
                # Convert PDF to images
                # NOTE: On Windows, poppler must be in PATH or specified via poppler_path
                images = convert_from_path(temp_file_path)
                text_chunks: list[str] = []
                for i, image in enumerate(images):
                    text = str(pytesseract.image_to_string(image))
                    text_chunks.append(f"--- Page {i+1} ---\n{text}")
                extracted_text = "\n\n".join(text_chunks)
            else:
                # Process image
                image = Image.open(temp_file_path)
                extracted_text = pytesseract.image_to_string(image)
        finally:
            # Clean up the temp file
            if os.path.exists(temp_file_path):
                os.remove(temp_file_path)

        # Handle empty text
        if not extracted_text.strip():
            # Not raising error, maybe the image was truly empty. Just returning empty text.
            pass

        return JSONResponse(content={
            "success": True,
            "filename": file.filename,
            "extracted_text": extracted_text.strip()
        })
        
    except pytesseract.TesseractNotFoundError:
        print("Tesseract not found. Make sure Tesseract-OCR is installed and in your PATH.")
        raise HTTPException(status_code=500, detail="OCR Engine (Tesseract) not found on the server.")
    except Exception as e:
        print(f"Error during extraction: {e}")
        raise HTTPException(status_code=500, detail=f"Error extracting text: {str(e)}")

# GEMINI_API_KEY support
GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY")

@app.post("/generate-mcqs")
def generate_mcqs(request: MCQRequest):
    """
    Accepts extracted text and returns generated MCQs.
    First tries regex extraction, then Gemini (if key), then falls back to local AI.
    """
    if not request.extracted_text or not request.extracted_text.strip():
        raise HTTPException(status_code=400, detail="Empty text provided")
        
    try:
        from mcq_parser import process_text_into_mcqs
        mcqs = process_text_into_mcqs(request.extracted_text, api_key=GEMINI_API_KEY)
        
        if not mcqs:
            # Try to produce at least one MCQ if everything else failed
            raise HTTPException(status_code=404, detail="Could not generate valid MCQs from the provided text.")
            
        return JSONResponse(content={
            "success": True,
            "mcqs": mcqs
        })
    except HTTPException:
        raise
    except Exception as e:
        print(f"Error during MCQ generation: {e}")
        raise HTTPException(status_code=500, detail=f"Error generating MCQs: {str(e)}")
@app.post("/translate")
async def translate_text(request: TranslationRequest):
    """
    Translates text or a list of texts into the target language.
    Defaults to Telugu (tel_Telu).
    """
    translator = get_translator()
    
    # NLLB lang codes: tel_Telu for Telugu
    tgt_lang = "tel_Telu" if request.target_language == "tel" else request.target_language
    
    is_list = isinstance(request.text, list)
    texts_to_translate = request.text if is_list else [request.text]
    
    results = []
    for text in texts_to_translate:
        cache_key = f"{tgt_lang}:{text}"
        if cache_key in _translation_cache:
            results.append(_translation_cache[cache_key])
        else:
            # Perform translation
            # Note: src_lang="eng_Latn" for English
            translation = translator(text, src_lang="eng_Latn", tgt_lang=tgt_lang)
            translated_text = translation[0]['translation_text']
            _translation_cache[cache_key] = translated_text
            results.append(translated_text)
            
    return JSONResponse(content={
        "success": True,
        "translated_text": results if is_list else results[0]
    })

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
