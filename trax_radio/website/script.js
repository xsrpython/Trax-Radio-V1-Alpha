// Trax Radio UK Website JavaScript

document.addEventListener('DOMContentLoaded', function () {
    // Smooth scrolling for navigation links
    const navLinks = document.querySelectorAll('nav a[href^="#"]');

    navLinks.forEach(link => {
        link.addEventListener('click', function (e) {
            e.preventDefault();
            const targetId = this.getAttribute('href');
            const targetSection = document.querySelector(targetId);

            if (targetSection) {
                targetSection.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });

    // Download button analytics (optional)
    const downloadBtn = document.querySelector('.btn-download');
    if (downloadBtn) {
        downloadBtn.addEventListener('click', function () {
            // Track download clicks (you can add analytics here)
            console.log('Download button clicked');

            // Optional: Show download started message
            this.innerHTML = '<span class="download-icon">⏳</span> Download Starting...';

            // Reset button after 3 seconds
            setTimeout(() => {
                this.innerHTML = '<span class="download-icon">📱</span> Download APK';
            }, 3000);
        });
    }

    // Mobile menu toggle (if you add one later)
    function initMobileMenu() {
        const mobileMenuBtn = document.querySelector('.mobile-menu-btn');
        const mobileMenu = document.querySelector('.mobile-menu');

        if (mobileMenuBtn && mobileMenu) {
            mobileMenuBtn.addEventListener('click', function () {
                mobileMenu.classList.toggle('active');
            });
        }
    }

    // Initialize mobile menu
    initMobileMenu();

    // Add scroll effect to header
    function initScrollEffect() {
        const header = document.querySelector('header');
        let lastScrollY = window.scrollY;

        window.addEventListener('scroll', function () {
            const currentScrollY = window.scrollY;

            if (currentScrollY > 100) {
                header.style.background = 'rgba(255, 255, 255, 0.98)';
                header.style.boxShadow = '0 2px 20px rgba(0, 0, 0, 0.15)';
            } else {
                header.style.background = 'rgba(255, 255, 255, 0.95)';
                header.style.boxShadow = '0 2px 20px rgba(0, 0, 0, 0.1)';
            }

            lastScrollY = currentScrollY;
        });
    }

    // Initialize scroll effect
    initScrollEffect();

    // Add loading animation for images
    function initImageLoading() {
        const images = document.querySelectorAll('img');

        images.forEach(img => {
            img.addEventListener('load', function () {
                this.style.opacity = '1';
            });

            // Set initial opacity for smooth loading
            img.style.opacity = '0';
            img.style.transition = 'opacity 0.3s ease';
        });
    }

    // Initialize image loading
    initImageLoading();

    // Add feature card hover effects
    function initFeatureCards() {
        const featureCards = document.querySelectorAll('.feature-card');

        featureCards.forEach(card => {
            card.addEventListener('mouseenter', function () {
                this.style.transform = 'translateY(-10px)';
                this.style.boxShadow = '0 8px 30px rgba(0, 0, 0, 0.15)';
            });

            card.addEventListener('mouseleave', function () {
                this.style.transform = 'translateY(0)';
                this.style.boxShadow = '0 4px 20px rgba(0, 0, 0, 0.1)';
            });
        });
    }

    // Initialize feature cards
    initFeatureCards();

    // Add download section animation
    function initDownloadAnimation() {
        const downloadSection = document.querySelector('.download-section');
        const downloadCard = document.querySelector('.download-card');

        if (downloadSection && downloadCard) {
            const observer = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        downloadCard.style.animation = 'slideInUp 0.6s ease forwards';
                    }
                });
            }, { threshold: 0.1 });

            observer.observe(downloadSection);
        }
    }

    // Initialize download animation
    initDownloadAnimation();

    // Add CSS animation keyframes
    const style = document.createElement('style');
    style.textContent = `
        @keyframes slideInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        .download-card {
            opacity: 0;
        }
    `;
    document.head.appendChild(style);
});

// Utility functions
function showNotification(message, type = 'info') {
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.textContent = message;

    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: ${type === 'success' ? '#4CAF50' : type === 'error' ? '#f44336' : '#1976D2'};
        color: white;
        padding: 15px 20px;
        border-radius: 8px;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        z-index: 10000;
        animation: slideInRight 0.3s ease;
    `;

    document.body.appendChild(notification);

    setTimeout(() => {
        notification.style.animation = 'slideOutRight 0.3s ease forwards';
        setTimeout(() => {
            document.body.removeChild(notification);
        }, 300);
    }, 3000);
}

// Add notification animations
const notificationStyle = document.createElement('style');
notificationStyle.textContent = `
    @keyframes slideInRight {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
    
    @keyframes slideOutRight {
        from {
            transform: translateX(0);
            opacity: 1;
        }
        to {
            transform: translateX(100%);
            opacity: 0;
        }
    }
`;
document.head.appendChild(notificationStyle);



