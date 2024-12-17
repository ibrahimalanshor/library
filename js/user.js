const admin = require("firebase-admin");
const { initializeApp } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');
const serviceAccount = require('./sdk/ddlib.json');
const fs = require('fs')
const { parse } = require('csv-parse')

initializeApp({
    credential: admin.credential.cert(serviceAccount)
})

const auth = getAuth()

async function attachAdminRole(uid) {
    await auth.setCustomUserClaims(uid, { admin: true })
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
async function setupUsers() {
    const parser = fs
        .createReadStream(`${__dirname}/data/siswa.csv`)
        .pipe(parse({ columns: true }));

    for await (const record of parser) {
        const [name, birthdate, email] = Object.values(record)

        try {
            await auth.getUserByEmail(email)
        } catch (err) {
            if (err.code === 'auth/user-not-found') {
                await auth.createUser({
                    email,
                    displayName: name,
                    password: birthdate,
                })
            }
        }
    }
}
async function listAllUsers() {
    const users = await getAuth().listUsers()

    users.users.forEach(user => console.log(user))
}

async function run() {
    await setupAdmin()
    await setupUsers()

    process.exit(1)
}

run()