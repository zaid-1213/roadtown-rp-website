require('dotenv').config();
const express = require('express');
const session = require('express-session');
const passport = require('passport');
const DiscordStrategy = require('passport-discord').Strategy;
const SteamStrategy = require('passport-steam').Strategy;
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = process.env.PORT || 3000;

// ============================================
// DATABASE (JSON file)
// ============================================
const DB_PATH = path.join(__dirname, 'data', 'users.json');

function ensureDB() {
    const dir = path.dirname(DB_PATH);
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
    if (!fs.existsSync(DB_PATH)) fs.writeFileSync(DB_PATH, JSON.stringify({ users: [], admins: ['1047671196214362265'] }, null, 2));
}

function readDB() {
    ensureDB();
    return JSON.parse(fs.readFileSync(DB_PATH, 'utf8'));
}

function writeDB(data) {
    ensureDB();
    fs.writeFileSync(DB_PATH, JSON.stringify(data, null, 2));
}

function saveUser(user) {
    const db = readDB();
    const idx = db.users.findIndex(u => u.id === user.id && u.provider === user.provider);
    const now = new Date().toISOString();
    if (idx >= 0) {
        db.users[idx].username = user.username;
        db.users[idx].avatar = user.avatar;
        db.users[idx].lastLogin = now;
        db.users[idx].loginCount = (db.users[idx].loginCount || 0) + 1;
    } else {
        db.users.push({
            ...user,
            registeredAt: now,
            lastLogin: now,
            loginCount: 1
        });
    }
    writeDB(db);
}

function isAdmin(userId) {
    const db = readDB();
    return db.admins.includes(String(userId));
}

// ============================================
// SESSION & PASSPORT
// ============================================
app.use(express.json());

// Trust proxy for Render/Railway (needed for secure cookies behind reverse proxy)
if (process.env.NODE_ENV === 'production') {
    app.set('trust proxy', 1);
}

app.use(session({
    secret: process.env.SESSION_SECRET || 'roadtown-secret',
    resave: false,
    saveUninitialized: false,
    cookie: {
        maxAge: 24 * 60 * 60 * 1000,
        secure: process.env.NODE_ENV === 'production',
        sameSite: process.env.NODE_ENV === 'production' ? 'lax' : 'lax'
    }
}));

app.use(passport.initialize());
app.use(passport.session());

passport.serializeUser((user, done) => done(null, user));
passport.deserializeUser((obj, done) => done(null, obj));

// Base URL for callbacks (auto-detect or use env)
const BASE_URL = process.env.BASE_URL || process.env.RENDER_EXTERNAL_URL || `http://localhost:${PORT}`;

// Discord Strategy
if (process.env.DISCORD_CLIENT_ID && process.env.DISCORD_CLIENT_ID !== 'YOUR_DISCORD_CLIENT_ID') {
    passport.use(new DiscordStrategy({
        clientID: process.env.DISCORD_CLIENT_ID,
        clientSecret: process.env.DISCORD_CLIENT_SECRET,
        callbackURL: process.env.DISCORD_CALLBACK_URL || `${BASE_URL}/auth/discord/callback`,
        scope: ['identify', 'email']
    }, (accessToken, refreshToken, profile, done) => {
        const user = {
            id: profile.id,
            username: profile.username,
            avatar: profile.avatar ? `https://cdn.discordapp.com/avatars/${profile.id}/${profile.avatar}.png` : null,
            email: profile.email || null,
            provider: 'discord'
        };
        saveUser(user);
        user.isAdmin = isAdmin(profile.id);
        return done(null, user);
    }));
}

// Steam Strategy
if (process.env.STEAM_API_KEY && process.env.STEAM_API_KEY !== 'YOUR_STEAM_API_KEY') {
    passport.use(new SteamStrategy({
        returnURL: process.env.STEAM_CALLBACK_URL || `${BASE_URL}/auth/steam/callback`,
        realm: BASE_URL + '/',
        apiKey: process.env.STEAM_API_KEY
    }, (identifier, profile, done) => {
        const user = {
            id: profile.id,
            username: profile.displayName,
            avatar: profile.photos[2] ? profile.photos[2].value : null,
            provider: 'steam'
        };
        saveUser(user);
        user.isAdmin = isAdmin(profile.id);
        return done(null, user);
    }));
}

// ============================================
// AUTH ROUTES
// ============================================
app.get('/auth/status', (req, res) => {
    if (req.isAuthenticated()) {
        res.json({ loggedIn: true, user: { ...req.user, isAdmin: isAdmin(req.user.id) } });
    } else {
        res.json({ loggedIn: false });
    }
});

app.get('/auth/discord', passport.authenticate('discord'));
app.get('/auth/discord/callback',
    passport.authenticate('discord', { failureRedirect: '/login.html?error=discord' }),
    (req, res) => res.redirect('/login.html?success=true')
);

app.get('/auth/steam', passport.authenticate('steam'));
app.get('/auth/steam/callback',
    passport.authenticate('steam', { failureRedirect: '/login.html?error=steam' }),
    (req, res) => res.redirect('/login.html?success=true')
);

app.get('/auth/logout', (req, res) => {
    req.logout(() => { res.redirect('/index.html'); });
});

// ============================================
// MIDDLEWARE
// ============================================
function requireAuth(req, res, next) {
    if (req.isAuthenticated()) return next();
    res.redirect('/login.html?redirect=' + encodeURIComponent(req.originalUrl));
}

function requireAdmin(req, res, next) {
    if (req.isAuthenticated() && isAdmin(req.user.id)) return next();
    if (req.isAuthenticated()) return res.status(403).json({ error: 'ليس لديك صلاحية الوصول' });
    res.redirect('/login.html?redirect=' + encodeURIComponent(req.originalUrl));
}

const OWNER_ID = '1047671196214362265';

function requireOwner(req, res, next) {
    if (req.isAuthenticated() && String(req.user.id) === OWNER_ID) return next();
    if (req.isAuthenticated()) return res.status(403).json({ error: 'فقط المالك يمكنه تنفيذ هذا الإجراء' });
    res.redirect('/login.html?redirect=' + encodeURIComponent(req.originalUrl));
}

// ============================================
// ADMIN API
// ============================================
app.get('/api/admin/users', requireAdmin, (req, res) => {
    const db = readDB();
    const users = db.users.map(u => ({
        ...u,
        isAdmin: db.admins.includes(u.id)
    }));
    res.json({ users, totalUsers: users.length });
});

app.post('/api/admin/add-admin', requireOwner, (req, res) => {
    const { userId } = req.body;
    if (!userId) return res.status(400).json({ error: 'userId مطلوب' });
    const db = readDB();
    if (!db.admins.includes(String(userId))) {
        db.admins.push(String(userId));
        writeDB(db);
    }
    res.json({ success: true, message: 'تمت إضافة الأدمن بنجاح' });
});

app.post('/api/admin/remove-admin', requireOwner, (req, res) => {
    const { userId } = req.body;
    if (!userId) return res.status(400).json({ error: 'userId مطلوب' });
    if (userId === '1047671196214362265') return res.status(400).json({ error: 'لا يمكن إزالة المالك' });
    const db = readDB();
    db.admins = db.admins.filter(id => id !== String(userId));
    writeDB(db);
    res.json({ success: true, message: 'تمت إزالة الأدمن بنجاح' });
});

app.post('/api/admin/delete-user', requireAdmin, (req, res) => {
    const { userId, provider } = req.body;
    const db = readDB();
    db.users = db.users.filter(u => !(u.id === userId && u.provider === provider));
    writeDB(db);
    res.json({ success: true, message: 'تم حذف المستخدم' });
});

// ============================================
// PROTECTED PAGES
// ============================================
app.get('/shop.html', requireAuth, (req, res) => {
    res.sendFile(path.join(__dirname, 'shop.html'));
});

app.get('/features.html', requireAuth, (req, res) => {
    res.sendFile(path.join(__dirname, 'features.html'));
});

app.get('/admin.html', requireAdmin, (req, res) => {
    res.sendFile(path.join(__dirname, 'admin.html'));
});

// Serve static files
app.use(express.static(__dirname));

app.listen(PORT, '0.0.0.0', () => {
    console.log(`\n🚀 Road Town RP Website running at http://localhost:${PORT}`);
    console.log(`🌐 Network access: http://YOUR_IP:${PORT}`);
    console.log(`\n📋 Setup checklist:`);
    if (!process.env.DISCORD_CLIENT_ID || process.env.DISCORD_CLIENT_ID === 'YOUR_DISCORD_CLIENT_ID') {
        console.log('   ❌ Discord: Set DISCORD_CLIENT_ID & DISCORD_CLIENT_SECRET in .env');
    } else {
        console.log('   ✅ Discord OAuth2 configured');
    }
    if (!process.env.STEAM_API_KEY || process.env.STEAM_API_KEY === 'YOUR_STEAM_API_KEY') {
        console.log('   ❌ Steam: Set STEAM_API_KEY in .env');
    } else {
        console.log('   ✅ Steam OpenID configured');
    }
    console.log(`   👑 Admin IDs: ${readDB().admins.join(', ')}`);
    console.log('');
});
