import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";
import { getStorage } from "firebase/storage";

const firebaseConfig = {
    apiKey: "AIzaSyCHNJVgNNvieiZQS4-eyJaC1TsFfrolpPg",
    authDomain: "chat-566.firebaseapp.com",
    databaseURL: "https://chat-566-default-rtdb.firebaseio.com",
    projectId: "chat-566",
    storageBucket: "chat-566.firebasestorage.app",
    messagingSenderId: "418881153944",
    appId: "1:418881153944:web:34c7f48b5a0b0984c919ed"
};

const app = initializeApp(firebaseConfig);

export const auth = getAuth(app);
export const db = getFirestore(app);
export const storage = getStorage(app);

export default app;
