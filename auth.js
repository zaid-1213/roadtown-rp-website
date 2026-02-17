// ============================================
// ROAD TOWN RP - AUTH SYSTEM
// ============================================

let currentUser = null;

// Detect if running on a static host (no backend)
const isStaticMode = (() => {
    const host = window.location.hostname;
    // Backend mode: localhost with port, or Render/Railway deployment
    if (host === 'localhost' || host === '127.0.0.1') return !window.location.port;
    if (host.endsWith('.onrender.com') || host.endsWith('.railway.app')) return false;
    // Any other host with our backend routes available = not static
    return true;
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
        if (data.loggedIn) {
            currentUser = data.user;
            onLoginSuccess(data.user);
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
        const provider = params.get('error');
        if (typeof showNotification === 'function') {
            showNotification(`فشل تسجيل الدخول عبر ${provider === 'discord' ? 'Discord' : 'Steam'}. حاول مرة أخرى.`, 'error');
        }
    }

    // Handle redirect param on login page
    if (params.get('redirect') && !params.get('success')) {
        if (typeof showNotification === 'function') {
            showNotification('يجب تسجيل الدخول أولاً للوصول لهذه الصفحة', 'info');
        }
    }
});
