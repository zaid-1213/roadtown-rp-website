// ============================================
// ROAD TOWN RP - HOME PAGE SCRIPTS
// ============================================

document.addEventListener('DOMContentLoaded', () => {
    createParticles();
    animateCounters();
    initScrollAnimations();
    fetchFiveMStatus();
    setInterval(fetchFiveMStatus, 30000);
});

// Particle System
function createParticles() {
    const container = document.getElementById('particles');
    if (!container) return;
    
    const particleCount = 40;
    
    for (let i = 0; i < particleCount; i++) {
        const particle = document.createElement('div');
        particle.className = 'particle';
        particle.style.left = Math.random() * 100 + '%';
        particle.style.width = (Math.random() * 4 + 2) + 'px';
        particle.style.height = particle.style.width;
        particle.style.animationDelay = Math.random() * 8 + 's';
        particle.style.animationDuration = (Math.random() * 6 + 5) + 's';
        
        const colors = ['#ffd700', '#ffed4e', '#f7931e', '#ffffff'];
        particle.style.background = colors[Math.floor(Math.random() * colors.length)];
        
        container.appendChild(particle);
    }
}

// Counter Animation
function animateCounters() {
    const counters = document.querySelectorAll('[data-count]');
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const el = entry.target;
                const target = parseInt(el.getAttribute('data-count'));
                let current = 0;
                const increment = target / 60;
                const duration = 2000;
                const stepTime = duration / 60;
                
                const timer = setInterval(() => {
                    current += increment;
                    if (current >= target) {
                        current = target;
                        clearInterval(timer);
                    }
                    el.textContent = Math.floor(current) + '+';
                }, stepTime);
                
                observer.unobserve(el);
            }
        });
    }, { threshold: 0.5 });
    
    counters.forEach(counter => observer.observe(counter));
}

// FiveM Server Status
async function fetchFiveMStatus() {
    const playersEl = document.getElementById('fivem-players');
    const statusEl = document.getElementById('fivem-status');
    const maxEl = document.getElementById('fivem-max');
    
    if (!playersEl || !statusEl || !maxEl) return;
    
    try {
        const res = await fetch('/api/fivem/status');
        const data = await res.json();
        
        const footerStatus = document.getElementById('footer-status');
        const footerPlayers = document.getElementById('footer-players');
        
        if (data.online) {
            playersEl.textContent = data.players;
            playersEl.setAttribute('data-count', data.players);
            statusEl.textContent = 'متصل';
            statusEl.style.color = '#4ade80';
            maxEl.textContent = data.maxPlayers;
            maxEl.setAttribute('data-count', data.maxPlayers);
            if (footerStatus) footerStatus.textContent = 'الحالة: متصل ✅';
            if (footerPlayers) footerPlayers.textContent = `اللاعبين: ${data.players}/${data.maxPlayers}`;
        } else {
            playersEl.textContent = '0';
            statusEl.textContent = 'غير متصل';
            statusEl.style.color = '#f87171';
            maxEl.textContent = '0';
            if (footerStatus) footerStatus.textContent = 'الحالة: غير متصل ❌';
            if (footerPlayers) footerPlayers.textContent = 'اللاعبين: 0/0';
        }
    } catch (e) {
        if (statusEl) {
            statusEl.textContent = 'غير متصل';
            statusEl.style.color = '#f87171';
        }
        const footerStatus = document.getElementById('footer-status');
        if (footerStatus) footerStatus.textContent = 'الحالة: غير متصل ❌';
    }
}

// Scroll Animations
function initScrollAnimations() {
    const animElements = document.querySelectorAll(
        '.home-feature-card, .home-server-text, .home-server-visual, .home-cta-content, .home-section-header'
    );
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('home-visible');
                observer.unobserve(entry.target);
            }
        });
    }, { threshold: 0.15, rootMargin: '0px 0px -50px 0px' });
    
    animElements.forEach(el => {
        el.classList.add('home-animate');
        observer.observe(el);
    });
}
