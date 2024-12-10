const admin = require("firebase-admin");
const { initializeApp } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');
const serviceAccount = require('./sdk/ddlib.json');

initializeApp({
    credential: admin.credential.cert(serviceAccount)
})

const auth = getAuth()

async function attachAdminRole(uid) {
    await auth.setCustomUserClaims(uid, { admin: true })

    process.exit(1)
}
async function createAdmin() {
    const admin = await auth.createUser({
        email: 'admin@gmail.com',
        displayName: 'Admin',
        password: 'password',
    })

    await attachAdminRole(admin.uid)
}
async function setupAdmin() {
    try {
        const admin = await auth.getUserByEmail('admin@gmail.com')

        await attachAdminRole(admin.uid)
    } catch (err) {
        await createAdmin()
    }
}

setupAdmin()