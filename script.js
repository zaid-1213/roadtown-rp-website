// ============================================
// ROAD TOWN RP - MAIN SCRIPT
// ============================================

// Notification System
function showNotification(message, type = 'info') {
    const overlay = document.createElement('div');
    overlay.style.cssText = `
        position: fixed; top: 0; left: 0; width: 100%; height: 100%;
        background: rgba(0,0,0,0.6); z-index: 9999;
        display: flex; align-items: center; justify-content: center;
        opacity: 0; transition: opacity .4s ease;
    `;

    const notification = document.createElement('div');
    const colors = { success: '#22c55e', error: '#ef4444', info: '#e67e22' };
    const icons = { success: '✅', error: '❌', info: 'ℹ️' };
    notification.style.cssText = `
        background: #1a1a2e; border: 2px solid ${colors[type] || colors.info};
        color: #fff; padding: 2rem 2.5rem; border-radius: 16px;
        font-family: 'Tajawal', sans-serif; box-shadow: 0 20px 60px rgba(0,0,0,0.5);
        font-size: 1.1rem; font-weight: 700; text-align: center;
        max-width: 450px; width: 90%; transform: scale(0.8);
        transition: transform .4s cubic-bezier(.4,0,.2,1);
    `;
    notification.innerHTML = `
        <div style="font-size:2.5rem;margin-bottom:0.8rem;">${icons[type] || icons.info}</div>
        <div style="line-height:1.8;">${message}</div>
        <div style="margin-top:1rem;height:4px;background:rgba(255,255,255,0.1);border-radius:4px;overflow:hidden;">
            <div style="height:100%;background:${colors[type] || colors.info};width:100%;animation:notifTimer 5s linear forwards;"></div>
        </div>
    `;

    const style = document.createElement('style');
    style.textContent = '@keyframes notifTimer{from{width:100%}to{width:0%}}';
    document.head.appendChild(style);

    overlay.appendChild(notification);
    document.body.appendChild(overlay);

    requestAnimationFrame(() => {
        overlay.style.opacity = '1';
        notification.style.transform = 'scale(1)';
    });

    overlay.addEventListener('click', (e) => {
        if (e.target === overlay) closeNotif();
    });

    function closeNotif() {
        overlay.style.opacity = '0';
        notification.style.transform = 'scale(0.8)';
        setTimeout(() => { overlay.remove(); style.remove(); }, 400);
    }

    setTimeout(closeNotif, 5000);
}

// Shopping Cart
let cart = [];

function addToCart(carId, carName, carPrice) {
    carId = String(carId);
    const existing = cart.find(i => i.id === carId);
    if (existing) {
        existing.quantity++;
        showNotification(`تم زيادة كمية ${carName}`, 'success');
    } else {
        cart.push({ id: carId, name: carName, price: carPrice, quantity: 1 });
        showNotification(`تمت إضافة ${carName} إلى السلة`, 'success');
    }
    updateCartDisplay();
    openCart();
}

function removeFromCart(carId) {
    carId = String(carId);
    cart = cart.filter(i => i.id !== carId);
    updateCartDisplay();
    showNotification('تم حذف العنصر من السلة', 'info');
    if (cart.length === 0) closeCart();
}

function updateQuantity(carId, change) {
    carId = String(carId);
    const item = cart.find(i => i.id === carId);
    if (item) {
        item.quantity += change;
        if (item.quantity < 1) {
            removeFromCart(carId);
        } else {
            updateCartDisplay();
        }
    }
}

function updateCartDisplay() {
    const cartItems = document.getElementById('cartItems');
    const cartTotal = document.getElementById('cartTotal');
    const toggleBtn = document.querySelector('.cart-toggle-btn');
    if (!cartItems || !cartTotal) return;

    // Update badge
    if (toggleBtn) {
        const totalItems = cart.reduce((s, i) => s + i.quantity, 0);
        let badge = toggleBtn.querySelector('.cart-count');
        if (totalItems > 0) {
            toggleBtn.classList.add('has-items');
            if (!badge) {
                badge = document.createElement('span');
                badge.className = 'cart-count';
                toggleBtn.appendChild(badge);
            }
            badge.textContent = totalItems;
        } else {
            toggleBtn.classList.remove('has-items');
            if (badge) badge.remove();
        }
    }

    if (cart.length === 0) {
        cartItems.innerHTML = '<p class="empty-cart">عربة التسوق فارغة</p>';
        cartTotal.textContent = '0 ريال';
    } else {
        let html = '';
        let total = 0;
        cart.forEach(item => {
            total += item.price * item.quantity;
            html += `
                <div class="cart-item">
                    <div class="cart-item-info">
                        <span class="cart-item-name">${item.name}</span>
                        <span class="cart-item-price">${item.price.toLocaleString()} ريال</span>
                        <div class="cart-item-row">
                            <div class="cart-item-quantity">
                                <button class="quantity-btn" onclick="updateQuantity('${item.id}', -1)">−</button>
                                <span class="quantity-display">${item.quantity}</span>
                                <button class="quantity-btn" onclick="updateQuantity('${item.id}', 1)">+</button>
                            </div>
                            <button class="cart-item-remove" onclick="removeFromCart('${item.id}')">×</button>
                        </div>
                    </div>
                </div>`;
        });
        cartItems.innerHTML = html;
        cartTotal.textContent = `${total.toLocaleString()} ريال`;
    }
}

function openCart() {
    const sidebar = document.getElementById('cartSidebar');
    const overlay = document.getElementById('cartOverlay');
    if (sidebar) sidebar.classList.add('visible');
    if (overlay) overlay.classList.add('visible');
}

function closeCart() {
    const sidebar = document.getElementById('cartSidebar');
    const overlay = document.getElementById('cartOverlay');
    if (sidebar) sidebar.classList.remove('visible');
    if (overlay) overlay.classList.remove('visible');
}

function toggleCart() {
    const sidebar = document.getElementById('cartSidebar');
    if (sidebar && sidebar.classList.contains('visible')) {
        closeCart();
    } else {
        openCart();
    }
}

function checkout() {
    if (cart.length === 0) {
        showNotification('عربة التسوق فارغة', 'error');
        return;
    }
    const total = cart.reduce((s, i) => s + (i.price * i.quantity), 0);
    showNotification(`جاري إتمام عملية شراء بقيمة ${total.toLocaleString()} ريال`, 'info');
    setTimeout(() => {
        showNotification('تم إرسال الطلب بنجاح! سيتم التواصل معك للدفع', 'success');
        cart = [];
        updateCartDisplay();
        closeCart();
    }, 2000);
}

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    // Cart toggle button - only show on shop page
    const isShopPage = window.location.pathname.includes('shop.html');
    if (isShopPage && !document.querySelector('.cart-toggle-btn')) {
        const btn = document.createElement('button');
        btn.className = 'cart-toggle-btn';
        btn.innerHTML = '🛒';
        btn.onclick = toggleCart;
        document.body.appendChild(btn);
    }

    // Cart overlay
    if (isShopPage && !document.getElementById('cartOverlay')) {
        const overlay = document.createElement('div');
        overlay.className = 'cart-overlay';
        overlay.id = 'cartOverlay';
        overlay.onclick = closeCart;
        document.body.appendChild(overlay);
    }

    // Cart sidebar
    if (isShopPage && !document.getElementById('cartSidebar')) {
        const sidebar = document.createElement('aside');
        sidebar.className = 'cart-sidebar';
        sidebar.id = 'cartSidebar';
        sidebar.innerHTML = `
            <div class="cart-header">
                <h3>🛒 عربة التسوق</h3>
                <button class="cart-close-btn" onclick="closeCart()">✕</button>
            </div>
            <div class="cart-items" id="cartItems">
                <p class="empty-cart">عربة التسوق فارغة</p>
            </div>
            <div class="cart-footer">
                <div class="cart-total">
                    <span>الإجمالي:</span>
                    <span id="cartTotal">0 ريال</span>
                </div>
                <button class="checkout-btn" onclick="checkout()">إتمام الشراء</button>
            </div>`;
        document.body.appendChild(sidebar);
    }

    // Add to cart buttons
    document.querySelectorAll('.add-to-cart').forEach(btn => {
        btn.addEventListener('click', function(e) {
            e.preventDefault();
            const id = this.getAttribute('data-car-id');
            const name = this.getAttribute('data-car-name');
            const price = parseInt(this.getAttribute('data-car-price'));
            if (id && name && price) addToCart(id, name, price);
        });
    });

    updateCartDisplay();
});
