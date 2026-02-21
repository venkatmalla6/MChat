import { initializeApp } from "firebase/app";
import { getDatabase } from "firebase/database";
import { getStorage } from "firebase/storage";

const firebaseConfig = {
    apiKey: "AIzaSyAwPqhmLCM1nZiH9JIZQ3lvRcv2SKLULyA",
    authDomain: "portfolio-6c111.firebaseapp.com",
    databaseURL: "https://portfolio-6c111-default-rtdb.firebaseio.com",
    projectId: "portfolio-6c111",
    storageBucket: "portfolio-6c111.firebasestorage.app",
    messagingSenderId: "1097964773205",
    appId: "1:1097964773205:web:fd2731dfdd966839fb59dc"
};

const app = initializeApp(firebaseConfig);
export const db = getDatabase(app);
export const storage = getStorage(app);
