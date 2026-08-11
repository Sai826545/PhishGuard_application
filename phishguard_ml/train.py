import os
import zipfile
import requests
import pandas as pd
import joblib
from sklearn.model_selection import train_test_split
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.naive_bayes import MultinomialNB
from sklearn.metrics import classification_report, accuracy_score

# Configuration
DATA_DIR = os.path.dirname(os.path.abspath(__file__))
SMS_ZIP_URL = "https://archive.ics.uci.edu/static/public/228/sms+spam+collection.zip"
SMS_ZIP_PATH = os.path.join(DATA_DIR, "smsspamcollection.zip")
SMS_FILE_PATH = os.path.join(DATA_DIR, "SMSSpamCollection")

EMAIL_FILE_PATH = os.path.join(DATA_DIR, "emails.csv")

# Output models
MODEL_SMS_PATH = os.path.join(DATA_DIR, "model_sms.joblib")
VEC_SMS_PATH = os.path.join(DATA_DIR, "vectorizer_sms.joblib")

MODEL_EMAIL_PATH = os.path.join(DATA_DIR, "model_email.joblib")
VEC_EMAIL_PATH = os.path.join(DATA_DIR, "vectorizer_email.joblib")

# For backward compatibility
LEGACY_MODEL_PATH = os.path.join(DATA_DIR, "model.joblib")
LEGACY_VEC_PATH = os.path.join(DATA_DIR, "vectorizer.joblib")

def download_data():
    # 1. SMS Dataset
    if not os.path.exists(SMS_FILE_PATH):
        print(f"Downloading SMS dataset from {SMS_ZIP_URL}...")
        response = requests.get(SMS_ZIP_URL, stream=True)
        with open(SMS_ZIP_PATH, 'wb') as f:
            for chunk in response.iter_content(chunk_size=1024):
                if chunk:
                    f.write(chunk)
        print("Extracting SMS ZIP...")
        with zipfile.ZipFile(SMS_ZIP_PATH, 'r') as zip_ref:
            zip_ref.extractall(DATA_DIR)
        if os.path.exists(SMS_ZIP_PATH):
            os.remove(SMS_ZIP_PATH)
    else:
        print("SMS dataset already exists locally.")

    # 2. Email Dataset
    if not os.path.exists(EMAIL_FILE_PATH):
        raise FileNotFoundError(f"Email dataset file not found at: {EMAIL_FILE_PATH}. Please paste 'emails.csv' inside this directory.")
    else:
        print("Email dataset verified locally.")

def train_sms_model():
    print("\n--- Training SMS Classifier ---")
    df = pd.read_csv(SMS_FILE_PATH, sep='\t', names=['label', 'message'])
    df['target'] = df['label'].map({'ham': 0, 'spam': 1})
    
    X_train, X_test, y_train, y_test = train_test_split(
        df['message'], df['target'], test_size=0.2, random_state=42, stratify=df['target']
    )
    
    vectorizer = TfidfVectorizer(stop_words='english', max_features=5000, ngram_range=(1, 2))
    X_train_vec = vectorizer.fit_transform(X_train)
    X_test_vec = vectorizer.transform(X_test)
    
    model = MultinomialNB(alpha=0.1)
    model.fit(X_train_vec, y_train)
    
    y_pred = model.predict(X_test_vec)
    print(f"SMS Accuracy: {accuracy_score(y_test, y_pred) * 100:.2f}%")
    print(classification_report(y_test, y_pred, target_names=['SMS HAM', 'SMS SPAM']))
    
    joblib.dump(vectorizer, VEC_SMS_PATH)
    joblib.dump(model, MODEL_SMS_PATH)
    
    # Legacy fallbacks
    joblib.dump(vectorizer, LEGACY_VEC_PATH)
    joblib.dump(model, LEGACY_MODEL_PATH)
    print("SMS models saved.")

def train_email_model():
    print("\n--- Training Email Classifier ---")
    df = pd.read_csv(EMAIL_FILE_PATH)
    # The dataset contains columns: label (0/1) and text (email body)
    # Filter out empty texts
    df = df.dropna(subset=['text'])
    
    X_train, X_test, y_train, y_test = train_test_split(
        df['text'], df['spam'], test_size=0.2, random_state=42, stratify=df['spam']
    )
    
    vectorizer = TfidfVectorizer(stop_words='english', max_features=10000, ngram_range=(1, 2))
    X_train_vec = vectorizer.fit_transform(X_train)
    X_test_vec = vectorizer.transform(X_test)
    
    model = MultinomialNB(alpha=0.1)
    model.fit(X_train_vec, y_train)
    
    y_pred = model.predict(X_test_vec)
    print(f"Email Accuracy: {accuracy_score(y_test, y_pred) * 100:.2f}%")
    print(classification_report(y_test, y_pred, target_names=['EMAIL HAM', 'EMAIL SPAM']))
    
    joblib.dump(vectorizer, VEC_EMAIL_PATH)
    joblib.dump(model, MODEL_EMAIL_PATH)
    print("Email models saved.")

def train_model():
    download_data()
    train_sms_model()
    train_email_model()
    print("\nTraining for both SMS and Email models complete!")

if __name__ == "__main__":
    train_model()
