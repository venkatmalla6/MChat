/**
 * auth.js — Centralised token helpers.
 * Token lives in sessionStorage when "Remember me" is OFF (cleared on tab/browser close)
 * and in localStorage when "Remember me" is ON (persists).
 */

export const getToken = () =>
    localStorage.getItem('token') || sessionStorage.getItem('token') || null;

/**
 * @param {string} token
 * @param {boolean} remember - true → localStorage, false → sessionStorage
 */
export const saveToken = (token, remember) => {
    if (remember) {
        localStorage.setItem('token', token);
        sessionStorage.removeItem('token');
    } else {
        sessionStorage.setItem('token', token);
        localStorage.removeItem('token');
    }
};

export const clearToken = () => {
    localStorage.removeItem('token');
    sessionStorage.removeItem('token');
    localStorage.removeItem('chat_id');
    sessionStorage.removeItem('chat_id');
    localStorage.removeItem('user_name');
    sessionStorage.removeItem('user_name');
    localStorage.removeItem('last_receiver');
    localStorage.removeItem('starred_convs');
};

export const saveUserMeta = (chatId, userName, remember) => {
    const storage = remember ? localStorage : sessionStorage;
    storage.setItem('chat_id', chatId || '');
    storage.setItem('user_name', userName || '');
};
