import cv2
import face_recognition
import pickle
import numpy as np
from datetime import datetime

# Load known face encodings
with open("known_encodings.pkl", "rb") as f:
    known_encodings = pickle.load(f)
known_names = list(known_encodings.keys())
known_face_encodings = list(known_encodings.values())

# Load the class photo
image_path = "class_photo.jpg"  # Replace with your image file
image = face_recognition.load_image_file(image_path)

# Find all face locations and encodings in the uploaded image
face_locations = face_recognition.face_locations(image)
face_encodings = face_recognition.face_encodings(image, face_locations)

# Prepare a list to record attendance
attendance = {}

# Convert image to BGR (for OpenCV)
image_bgr = cv2.cvtColor(image, cv2.COLOR_RGB2BGR)

# Loop through each detected face
for (top, right, bottom, left), face_encoding in zip(face_locations, face_encodings):
    # Compare detected face encoding with known encodings
    matches = face_recognition.compare_faces(known_face_encodings, face_encoding, tolerance=0.6)
    face_distances = face_recognition.face_distance(known_face_encodings, face_encoding)
    
    name = "Unknown"
    if matches:
        best_match_index = np.argmin(face_distances)
        if matches[best_match_index]:
            name = known_names[best_match_index]
            attendance[name] = True  # Mark student as present

    # Draw a box around the face
    cv2.rectangle(image_bgr, (left, top), (right, bottom), (0, 255, 0), 2)
    # Label the face with the name
    cv2.putText(image_bgr, name, (left, top - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.75, (0, 255, 0), 2)

# Save or display the annotated image
annotated_image_path = "annotated_class_photo.jpg"
cv2.imwrite(annotated_image_path, image_bgr)
cv2.imshow("Attendance", image_bgr)
cv2.waitKey(0)
cv2.destroyAllWindows()

# Print attendance record with timestamp
print("Attendance recorded on", datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
for student in known_names:
    status = "Present" if attendance.get(student, False) else "Absent"
    print(f"{student}: {status}")
