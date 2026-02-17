// Mobile Navigation Toggle
const hamburger = document.querySelector('.hamburger');
const navMenu = document.querySelector('.nav-menu');

hamburger.addEventListener('click', () => {
    hamburger.classList.toggle('active');
    navMenu.classList.toggle('active');
});

// Close mobile menu when clicking on a link
document.querySelectorAll('.nav-link').forEach(n => n.addEventListener('click', () => {
    hamburger.classList.remove('active');
    navMenu.classList.remove('active');
}));

// Smooth scrolling for navigation links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            target.scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        }
    });
});

// Form submission handler
const contactForm = document.querySelector('.contact-form');
if (contactForm) {
    contactForm.addEventListener('submit', function(e) {
        e.preventDefault();
        
        // Get form data
        const formData = new FormData(this);
        const name = this.querySelector('input[type="text"]').value;
        const email = this.querySelector('input[type="email"]').value;
        const message = this.querySelector('textarea').value;
        
        // Simple validation
        if (!name || !email || !message) {
            showNotification('يرجى ملء جميع الحقول المطلوبة', 'error');
            return;
        }
        
        // Email validation
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            showNotification('يرجى إدخال بريد إلكتروني صحيح', 'error');
            return;
        }
        
        // Simulate form submission
        showNotification('جاري إرسال رسالتك...', 'info');
        
        setTimeout(() => {
            showNotification('تم إرسال رسالتك بنجاح! سنتواصل معك قريباً.', 'success');
            this.reset();
        }, 2000);
    });
}

// Notification system
function showNotification(message, type = 'info') {
    // Remove existing notifications
    const existingNotification = document.querySelector('.notification');
    if (existingNotification) {
        existingNotification.remove();
    }
    
    // Create notification element
    const notification = document.createElement('div');
    notification.className = `notification ${type}`;
    notification.textContent = message;
    
    // Add styles
    notification.style.cssText = `
        position: fixed;
        top: 100px;
        right: 20px;
        padding: 15px 20px;
        border-radius: 5px;
        color: white;
        font-weight: 500;
        z-index: 10000;
        transform: translateX(100%);
        transition: transform 0.3s ease;
        max-width: 300px;
        box-shadow: 0 5px 15px rgba(0,0,0,0.2);
    `;
    
    // Set background color based on type
    switch(type) {
        case 'success':
            notification.style.background = '#28a745';
            break;
        case 'error':
            notification.style.background = '#dc3545';
            break;
        case 'info':
            notification.style.background = '#17a2b8';
            break;
        default:
            notification.style.background = '#6c757d';
    }
    
    // Add to page
    document.body.appendChild(notification);
    
    // Animate in
    setTimeout(() => {
        notification.style.transform = 'translateX(0)';
    }, 100);
    
    // Remove after 5 seconds
    setTimeout(() => {
        notification.style.transform = 'translateX(100%)';
        setTimeout(() => {
            if (notification.parentNode) {
                notification.remove();
            }
        }, 300);
    }, 5000);
}

// Scroll animations
const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
};

const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.style.opacity = '1';
            entry.target.style.transform = 'translateY(0)';
        }
    });
}, observerOptions);

// Observe elements for animation
document.addEventListener('DOMContentLoaded', () => {
    const animatedElements = document.querySelectorAll('.service-card, .about-text, .contact-info, .contact-form');
    
    animatedElements.forEach(el => {
        el.style.opacity = '0';
        el.style.transform = 'translateY(20px)';
        el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
        observer.observe(el);
    });
});

// Header scroll effect
window.addEventListener('scroll', () => {
    const header = document.querySelector('.header');
    if (window.scrollY > 100) {
        header.style.background = 'linear-gradient(135deg, rgba(255, 107, 53, 0.95) 0%, rgba(247, 147, 30, 0.95) 100%)';
        header.style.backdropFilter = 'blur(10px)';
    } else {
        header.style.background = 'linear-gradient(135deg, #ff6b35 0%, #f7931e 100%)';
        header.style.backdropFilter = 'none';
    }
});

// Connect to Server function
function connectToServer() {
    showNotification('جاري فتح FiveM...', 'info');
    
    // Simulate connection process
    setTimeout(() => {
        showNotification('انسخ هذا الرابط ولصقه في FiveM: connect.roadtown.sa', 'success');
        
        // Copy to clipboard
        navigator.clipboard.writeText('connect.roadtown.sa').then(() => {
            showNotification('تم نسخ الرابط تلقائياً!', 'success');
        }).catch(() => {
            showNotification('الرجاء نسخ الرابط يدوياً: connect.roadtown.sa', 'info');
        });
        
        // Also open Discord for support
        setTimeout(() => {
            showNotification('يمكنك الانضمام للديسكورد للحصول على الدعم', 'info');
        }, 2000);
    }, 1500);
}

// Package purchase handlers
document.addEventListener('DOMContentLoaded', () => {
    const packageBtns = document.querySelectorAll('.package-btn');
    
    packageBtns.forEach(btn => {
        btn.addEventListener('click', function() {
            const packageName = this.closest('.service-card').querySelector('h3').textContent;
            const packagePrice = this.closest('.service-card').querySelector('p').textContent;
            
            showNotification(`جاري تحويلك لشراء ${packageName} - ${packagePrice}`, 'info');
            
            setTimeout(() => {
                showNotification('يرجى التواصل مع الإدارة عبر الديسكورد لإتمام عملية الشراء', 'success');
            }, 2000);
        });
    });
    
    // Social media handlers
    const discordBtn = document.querySelector('.social-btn.discord');
    const youtubeBtn = document.querySelector('.social-btn.youtube');
    
    if (discordBtn) {
        discordBtn.addEventListener('click', (e) => {
            e.preventDefault();
            showNotification('جاري فتح الديسكورد...', 'info');
            // Open Discord invite directly
            window.open('https://discord.gg/QkdTEyjY', '_blank');
        });
    }
    
    if (youtubeBtn) {
        youtubeBtn.addEventListener('click', (e) => {
            e.preventDefault();
            showNotification('جاري فتح اليوتيوب...', 'info');
        });
    }
});

// Add loading animation
window.addEventListener('load', () => {
    document.body.style.opacity = '0';
    document.body.style.transition = 'opacity 0.5s ease';
    
    setTimeout(() => {
        document.body.style.opacity = '1';
    }, 100);
});
