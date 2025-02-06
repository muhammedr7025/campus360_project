import face_recognition
import os
import pickle

def encode_known_faces(known_faces_dir='known_students'):
    known_encodings = {}
    
    # Iterate over each image in the known_faces_dir
    for filename in os.listdir(known_faces_dir):
        if filename.endswith(('.jpg', '.jpeg', '.png')):
            image_path = os.path.join(known_faces_dir, filename)
            image = face_recognition.load_image_file(image_path)
            
            # Assuming one face per image
            encodings = face_recognition.face_encodings(image)
            if encodings:
                known_encodings[os.path.splitext(filename)[0]] = encodings[0]
            else:
                print(f"No face found in {filename}.")
    
    # Save the encodings to disk for future use
    with open("known_encodings.pkl", "wb") as f:
        pickle.dump(known_encodings, f)
    
    return known_encodings

# Run once to generate and store encodings
known_encodings = encode_known_faces()
