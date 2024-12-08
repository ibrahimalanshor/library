// index.js
const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
require('dotenv').config();
const data = require('./data.json');
const { populate } = require('dotenv');

const firebaseConfig = {
apiKey: process.env.FIREBASE_PUBLIC_API_KEY,
authDomain: process.env.FIREBASE_AUTH_DOMAIN,
projectId: process.env.FIREBASE_PROJECT_ID,
storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
messagingSenderId: process.env.FIREBASE_MESSAGING_SENDER_ID,
appId: process.env.FIREBASE_APP_ID,
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

const importJSON = async () => {
for await (const user of data) {
    db.collection('buku').doc().set({
        author: user.author,
        icon: `${user.title}.jpg`,
        rating: parseFloat(5),
        recomended: user.recommended,
        popular: user.popular,
        title: user.title
    });
}
};

importJSON();
