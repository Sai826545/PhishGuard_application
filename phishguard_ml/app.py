import os
import joblib
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List

# Setup FastAPI App
app = FastAPI(title="PhishGuard Machine Learning API", version="1.0.0")

# Load model and vectorizer
DATA_DIR = os.path.dirname(os.path.abspath(__file__))
VECTORIZER_PATH = os.path.join(DATA_DIR, "vectorizer.joblib")
MODEL_PATH = os.path.join(DATA_DIR, "model.joblib")

model = None
vectorizer = None

def load_model():
    global model, vectorizer
    if not os.path.exists(VECTORIZER_PATH) or not os.path.exists(MODEL_PATH):
        print("Warning: Model files not found. Please run train.py first to train the classifier.")
    else:
        print("Loading pre-trained classifier and vectorizer...")
        vectorizer = joblib.load(VECTORIZER_PATH)
        model = joblib.load(MODEL_PATH)
        print("Model loaded successfully.")

# Initial model load attempt
load_model()

class PredictRequest(BaseModel):
    content: str

class PredictResponse(BaseModel):
    riskScore: int
    status: str
    aiReasons: List[str]

@app.post("/predict", response_model=PredictResponse)
def predict(request: PredictRequest):
    global model, vectorizer
    # Retry load if model was trained after starting
    if model is None or vectorizer is None:
        load_model()

    text = request.content
    if not text or text.strip() == "":
        return PredictResponse(riskScore=0, status="SAFE", aiReasons=["Empty message content."])

    # Check if model loaded successfully
    if model is None or vectorizer is None:
        raise HTTPException(
            status_code=503, 
            detail="Machine learning model is currently offline or not trained."
        )

    try:
        # 1. Transform text
        vec_text = vectorizer.transform([text])
        
        # 2. Get probabilities
        # classes: [0, 1] where 0=ham/safe, 1=spam/dangerous
        probs = model.predict_proba(vec_text)[0]
        spam_prob = probs[1]
        
        # 3. Calculate risk score (0-100)
        risk_score = int(spam_prob * 100)
        
        # 4. Map to status
        if risk_score > 75:
            status = "DANGEROUS"
        elif risk_score > 35:
            status = "SUSPICIOUS"
        else:
            status = "SAFE"
            
        # 5. Extract Explainable AI Reasons
        feature_names = vectorizer.get_feature_names_out()
        tfidf_repr = vec_text.toarray()[0]
        # Log probability difference ratio (Spam vs Ham)
        ratios = model.feature_log_prob_[1] - model.feature_log_prob_[0]
        
        activated_terms = []
        for idx, val in enumerate(tfidf_repr):
            if val > 0:
                word = feature_names[idx]
                importance = ratios[idx] * val
                activated_terms.append((word, importance))
                
        # Sort by importance descending
        activated_terms.sort(key=lambda x: x[1], reverse=True)
        
        ai_reasons = []
        for word, val in activated_terms[:3]:
            # Highlight spam-contributing terms
            if val > 0.05:
                ai_reasons.append(f"AI: Triggers suspicious keyword '{word}'")

        if not ai_reasons:
            if status == "DANGEROUS":
                ai_reasons.append("AI: Message format and structure closely match phishing campaigns.")
            elif status == "SUSPICIOUS":
                ai_reasons.append("AI: Detected slight linguistic triggers resembling advertising spam.")
            else:
                ai_reasons.append("AI: Content is typical of safe, conversational communication.")
                
        print(f">>> [ML Model Prediction] Scanned message text. Risk Score: {risk_score}%, Status: {status}")
        return PredictResponse(
            riskScore=risk_score,
            status=status,
            aiReasons=ai_reasons
        )
        
    except Exception as e:
        raise HTTPException(
            status_code=500, 
            detail=f"Internal prediction model error: {str(e)}"
        )

@app.get("/health")
def health():
    global model
    if model is None:
        load_model()
    return {"status": "healthy", "model_loaded": model is not None}
