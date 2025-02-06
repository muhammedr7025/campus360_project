/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.createAuthUserOnUserCreation = functions.database
  .ref('/users/{uid}')
  .onCreate(async (snapshot, context) => {
    const userData = snapshot.val();
    const email = userData.email;
    try {
      // Create a new authentication user with default password "12345678"
      const userRecord = await admin.auth().createUser({
        email: email,
        password: "12345678",
      });
      console.log(`Created auth user for ${email}: ${userRecord.uid}`);
    } catch (error) {
      console.error(`Error creating auth user for ${email}:`, error);
    }
  });
  exports.deleteAuthUserOnUserDeletion = functions.database
  .ref('/users/{uid}')
  .onDelete(async (snapshot, context) => {
    const userData = snapshot.val();
    const email = userData.email;
    try {
      // Find the authentication user by email and then delete them
      const userRecord = await admin.auth().getUserByEmail(email);
      await admin.auth().deleteUser(userRecord.uid);
      console.log(`Deleted auth user for ${email}`);
    } catch (error) {
      console.error(`Error deleting auth user for ${email}:`, error);
    }
  });
