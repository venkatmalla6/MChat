/**
 * auth.js — Firebase Auth helpers.
 * Wraps Firebase Auth so the rest of the app has a clean interface.
 */

import { auth } from './firebase';
import {
    browserLocalPersistence,
    browserSessionPersistence,
    setPersistence,
    signOut,
    onAuthStateChanged,
} from 'firebase/auth';

/** Returns a promise that resolves to the current Firebase user (or null). */
export const getCurrentUser = () =>
    new Promise((resolve) => {
        const unsub = onAuthStateChanged(auth, (user) => {
            unsub();
            resolve(user);
        });
    });

/**
 * Set auth persistence based on "remember me" preference.
 * Call this BEFORE signInWithEmailAndPassword / createUserWithEmailAndPassword.
 * @param {boolean} remember - true → local (survives browser restart), false → session only
 */
export const applyPersistence = (remember) =>
    setPersistence(auth, remember ? browserLocalPersistence : browserSessionPersistence);

/** Sign out the current user and clear any local metadata. */
export const clearSession = async () => {
    localStorage.removeItem('last_receiver');
    localStorage.removeItem('starred_convs');
    await signOut(auth);
};

// ── Backward-compat shims (used in a few places in the codebase) ────────────

/** @deprecated Use getCurrentUser() + Firebase user instead */
export const getToken = async () => {
    const user = auth.currentUser;
    if (!user) return null;
    return user.getIdToken();
};

/** @deprecated No-op — Firebase handles persistence via applyPersistence() */
export const saveToken = () => { };

/** @deprecated Use clearSession() */
export const clearToken = () => clearSession();

/** @deprecated No-op — user metadata is now stored in Firestore */
export const saveUserMeta = () => { };
