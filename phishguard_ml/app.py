import os
import joblib
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List

# Setup FastAPI App
app = FastAPI(title="PhishGuard Machine Learning API", version="1.0.0")

# Model and vectorizer paths
DATA_DIR = os.path.dirname(os.path.abspath(__file__))
VEC_SMS_PATH = os.path.join(DATA_DIR, "vectorizer_sms.joblib")
MODEL_SMS_PATH = os.path.join(DATA_DIR, "model_sms.joblib")
VEC_EMAIL_PATH = os.path.join(DATA_DIR, "vectorizer_email.joblib")
MODEL_EMAIL_PATH = os.path.join(DATA_DIR, "model_email.joblib")

# Global models
model_sms = None
vec_sms = None
model_email = None
vec_email = None

def load_models():
    global model_sms, vec_sms, model_email, vec_email
    
    # 1. Load SMS Model
    if os.path.exists(MODEL_SMS_PATH) and os.path.exists(VEC_SMS_PATH):
        print("Loading pre-trained SMS classifier and vectorizer...")
        vec_sms = joblib.load(VEC_SMS_PATH)
        model_sms = joblib.load(MODEL_SMS_PATH)
    else:
        # Fallback to legacy path if exists
        legacy_model = os.path.join(DATA_DIR, "model.joblib")
        legacy_vec = os.path.join(DATA_DIR, "vectorizer.joblib")
        if os.path.exists(legacy_model) and os.path.exists(legacy_vec):
            print("Loading pre-trained SMS classifier and vectorizer (Legacy fallback)...")
            vec_sms = joblib.load(legacy_vec)
            model_sms = joblib.load(legacy_model)
        else:
            print("Warning: SMS model files not found.")
            
    # 2. Load Email Model
    if os.path.exists(MODEL_EMAIL_PATH) and os.path.exists(VEC_EMAIL_PATH):
        print("Loading pre-trained Email classifier and vectorizer...")
        vec_email = joblib.load(VEC_EMAIL_PATH)
        model_email = joblib.load(MODEL_EMAIL_PATH)
    else:
        print("Warning: Email model files not found.")

# Initial load
load_models()

class PredictRequest(BaseModel):
    content: str
    type: str = "SMS" # Default to SMS for backwards compatibility

class PredictResponse(BaseModel):
    riskScore: int
    status: str
    aiReasons: List[str]

@app.post("/predict", response_model=PredictResponse)
def predict(request: PredictRequest):
    global model_sms, vec_sms, model_email, vec_email
    
    text = request.content
    scan_type = request.type.upper()
    
    if not text or text.strip() == "":
        return PredictResponse(riskScore=0, status="SAFE", aiReasons=["Empty message content."])

    # Select active model and vectorizer
    if scan_type == "EMAIL":
        active_model = model_email
        active_vec = vec_email
        type_label = "Email"
    else:
        active_model = model_sms
        active_vec = vec_sms
        type_label = "SMS"

    # Reload if missing
    if active_model is None or active_vec is None:
        load_models()
        if scan_type == "EMAIL":
            active_model = model_email
            active_vec = vec_email
        else:
            active_model = model_sms
            active_vec = vec_sms

    if active_model is None or active_vec is None:
        raise HTTPException(
            status_code=503, 
            detail=f"Machine learning model for type '{type_label}' is currently offline or not trained."
        )

    try:
        # 1. Transform text
        vec_text = active_vec.transform([text])
        
        # 2. Get probabilities
        # classes: [0, 1] where 0=ham/safe, 1=spam/dangerous
        probs = active_model.predict_proba(vec_text)[0]
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
        feature_names = active_vec.get_feature_names_out()
        tfidf_repr = vec_text.toarray()[0]
        # Log probability difference ratio (Spam vs Ham)
        ratios = active_model.feature_log_prob_[1] - active_model.feature_log_prob_[0]
        
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
                ai_reasons.append(f"AI: {type_label} content structure strongly matches spam signature profiles.")
            elif status == "SUSPICIOUS":
                ai_reasons.append(f"AI: Detected minor linguistic anomalies resembling {type_label.lower()} spam.")
            else:
                ai_reasons.append(f"AI: Content is typical of safe, clean {type_label.lower()} communication.")
                
        print(f">>> [ML Model Prediction] Scanned {type_label} text. Risk Score: {risk_score}%, Status: {status}")
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
    global model_sms, model_email
    if model_sms is None or model_email is None:
        load_models()
    return {
        "status": "healthy", 
        "sms_model_loaded": model_sms is not None,
        "email_model_loaded": model_email is not None
    }
