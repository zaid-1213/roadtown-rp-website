// ============================================
// ROAD TOWN RP - AUTH SYSTEM
// ============================================

let currentUser = null;

// Detect if running on a static host (no backend)
const isStaticMode = (() => {
    const host = window.location.hostname;
    // Backend mode: localhost with port, or Render/Railway deployment, or direct IP access
    if (host === 'localhost' || host === '127.0.0.1') return !window.location.port;
    if (host.endsWith('.onrender.com') || host.endsWith('.railway.app')) return false;
    // Direct IP access with port = backend mode
    if (/^\d+\.\d+\.\d+\.\d+$/.test(host) && window.location.port) return false;
    // Any other host - try to detect backend by checking /auth/status
    return false;
})();

async function checkAuth() {
    // In static mode, show all pages to everyone
    if (isStaticMode) {
        onStaticMode();
        return { loggedIn: false };
    }
    try {
        const res = await fetch('/auth/status');
        const data = await res.json();
        if (data.loggedIn && data.fullyLinked) {
            currentUser = data.user;
            onLoginSuccess(data.user);
        } else if (data.loggedIn && !data.fullyLinked) {
            currentUser = data.user;
            onNeedSteamLink(data.user);
        } else {
            currentUser = null;
            onLoggedOut();
        }
        return data;
    } catch (e) {
        currentUser = null;
        onStaticMode();
        return { loggedIn: false };
    }
}

function onStaticMode() {
    // Show all nav links (no protection in static mode)
    document.querySelectorAll('.nav-protected').forEach(el => el.style.display = '');
    document.querySelectorAll('.nav-admin-link').forEach(el => el.style.display = 'none');
    document.querySelectorAll('.nav-login-link').forEach(el => el.style.display = '');
    document.querySelectorAll('.nav-user-info').forEach(el => {
        el.style.display = 'none';
        el.innerHTML = '';
    });
}

function onLoginSuccess(user) {
    // Update nav - show user info, hide login link
    document.querySelectorAll('.nav-login-link').forEach(el => el.style.display = 'none');
    document.querySelectorAll('.nav-user-info').forEach(el => {
        el.style.display = 'flex';
        el.innerHTML = `
            <img src="${user.avatar || 'assets/images/Main.png'}" alt="${user.username}" class="nav-avatar">
            <span class="nav-username">${user.username}</span>
            <a href="/auth/logout" class="nav-logout-btn" title="تسجيل خروج">✕</a>
        `;
    });

    // Show protected nav links
    document.querySelectorAll('.nav-protected').forEach(el => el.style.display = '');

    // Show admin link only for admins
    document.querySelectorAll('.nav-admin-link').forEach(el => {
        el.style.display = user.isAdmin ? '' : 'none';
    });

    // If on login page with success param, redirect
    const params = new URLSearchParams(window.location.search);
    if (params.get('success') === 'true') {
        const redirect = params.get('redirect') || '/index.html';
        window.location.href = redirect;
    }
}

function onNeedSteamLink(user) {
    // User logged in with Discord but needs to link Steam
    document.querySelectorAll('.nav-login-link').forEach(el => el.style.display = 'none');
    document.querySelectorAll('.nav-user-info').forEach(el => {
        el.style.display = 'flex';
        el.innerHTML = `
            <img src="${user.avatar || 'assets/images/Main.png'}" alt="${user.username}" class="nav-avatar">
            <span class="nav-username">${user.username}</span>
            <a href="/auth/steam" class="nav-logout-btn" title="ربط Steam" style="color:#66c0f4;">🔗</a>
        `;
    });

    // Hide protected nav links until fully linked
    document.querySelectorAll('.nav-protected').forEach(el => el.style.display = 'none');
    document.querySelectorAll('.nav-admin-link').forEach(el => el.style.display = 'none');

    // If on login page, show Steam link message
    const params = new URLSearchParams(window.location.search);
    if (params.get('needsteam') === 'true' || window.location.pathname.includes('login')) {
        if (typeof showNotification === 'function') {
            showNotification('تم تسجيل الدخول عبر Discord ✅ الآن اربط حساب Steam لإكمال التسجيل', 'info');
        }
    }
}

function onLoggedOut() {
    // Show login link, hide user info
    document.querySelectorAll('.nav-login-link').forEach(el => el.style.display = '');
    document.querySelectorAll('.nav-user-info').forEach(el => {
        el.style.display = 'none';
        el.innerHTML = '';
    });

    // Hide protected nav links
    document.querySelectorAll('.nav-protected').forEach(el => el.style.display = 'none');

    // Hide admin link
    document.querySelectorAll('.nav-admin-link').forEach(el => el.style.display = 'none');
}

function loginWithDiscord() {
    window.location.href = '/auth/discord';
}

function loginWithSteam() {
    window.location.href = '/auth/steam';
}

function logout() {
    window.location.href = '/auth/logout';
}

// Check auth on page load
document.addEventListener('DOMContentLoaded', () => {
    checkAuth();

    // Handle login page error messages
    const params = new URLSearchParams(window.location.search);
    if (params.get('error')) {
        const errorType = params.get('error');
        let msg = '';
        if (errorType === 'needsdiscord') msg = 'يجب تسجيل الدخول عبر Discord أولاً ثم ربط Steam';
        else if (errorType === 'discord') msg = 'فشل تسجيل الدخول عبر Discord. حاول مرة أخرى.';
        else if (errorType === 'steam') msg = 'فشل ربط حساب Steam. حاول مرة أخرى.';
        else msg = 'حدث خطأ. حاول مرة أخرى.';
        if (typeof showNotification === 'function') {
            showNotification(msg, 'error');
        }
    }

    // Handle redirect param on login page
    if (params.get('redirect') && !params.get('success')) {
        if (typeof showNotification === 'function') {
            showNotification('يجب تسجيل الدخول أولاً للوصول لهذه الصفحة', 'info');
        }
    }
});
