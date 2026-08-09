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
ZIP_URL = "https://archive.ics.uci.edu/static/public/228/sms+spam+collection.zip"
ZIP_PATH = os.path.join(DATA_DIR, "smsspamcollection.zip")
FILE_PATH = os.path.join(DATA_DIR, "SMSSpamCollection")
VECTORIZER_PATH = os.path.join(DATA_DIR, "vectorizer.joblib")
MODEL_PATH = os.path.join(DATA_DIR, "model.joblib")

def download_data():
    if os.path.exists(FILE_PATH):
        print("Dataset already exists locally.")
        return

    print(f"Downloading dataset from {ZIP_URL}...")
    response = requests.get(ZIP_URL, stream=True)
    with open(ZIP_PATH, 'wb') as f:
        for chunk in response.iter_content(chunk_size=1024):
            if chunk:
                f.write(chunk)
    
    print("Extracting ZIP contents...")
    with zipfile.ZipFile(ZIP_PATH, 'r') as zip_ref:
        zip_ref.extractall(DATA_DIR)
        
    # Clean up zip file
    if os.path.exists(ZIP_PATH):
        os.remove(ZIP_PATH)
    print("Dataset extracted successfully.")

def train_model():
    download_data()

    print("Loading data...")
    # The dataset is tab-separated: label \t message
    df = pd.read_csv(FILE_PATH, sep='\t', names=['label', 'message'])
    
    # Map label to binary target (1 for spam/dangerous, 0 for ham/safe)
    df['target'] = df['label'].map({'ham': 0, 'spam': 1})
    
    print("Splitting train/test sets...")
    X_train, X_test, y_train, y_test = train_test_split(
        df['message'], df['target'], test_size=0.2, random_state=42, stratify=df['target']
    )
    
    print("Training TF-IDF Vectorizer...")
    # Limit max features, remove english stop words, and use bi-grams for better context
    vectorizer = TfidfVectorizer(stop_words='english', max_features=5000, ngram_range=(1, 2))
    X_train_vec = vectorizer.fit_transform(X_train)
    X_test_vec = vectorizer.transform(X_test)
    
    print("Training Naive Bayes Classifier...")
    model = MultinomialNB(alpha=0.1) # alpha=0.1 for Lidstone smoothing
    model.fit(X_train_vec, y_train)
    
    print("Evaluating model...")
    y_pred = model.predict(X_test_vec)
    print(f"Accuracy: {accuracy_score(y_test, y_pred) * 100:.2f}%")
    print("\nClassification Report:")
    print(classification_report(y_test, y_pred, target_names=['HAM/SAFE', 'SPAM/DANGEROUS']))
    
    print(f"Saving Vectorizer to {VECTORIZER_PATH}...")
    joblib.dump(vectorizer, VECTORIZER_PATH)
    
    print(f"Saving Model to {MODEL_PATH}...")
    joblib.dump(model, MODEL_PATH)
    print("Training complete!")

if __name__ == "__main__":
    train_model()
