// 主题切换功能已由PaperMod主题内置处理

// 页面加载完成后执行
document.addEventListener('DOMContentLoaded', function() {
    // 主题切换由PaperMod主题内置处理
    
    // 初始化打字机效果
    const typingElement = document.getElementById('typing-text');
    if (typingElement && typeof Typed !== 'undefined') {
        // 清空元素内容，让 Typed.js 重新填充
        typingElement.innerHTML = '';
        
        new Typed('#typing-text', {
            strings: ['"Stay Hungry, Stay Foolish."'],
            typeSpeed: 80,
            startDelay: 1000,
            showCursor: true,
            cursorChar: '|',
            autoInsertCss: true,
            loop: false,  // 不循环
            fadeOut: false,
            fadeOutClass: 'typed-fade-out',
            fadeOutDelay: 0,
            onComplete: function() {
                // 打字完成后，立即隐藏光标
                setTimeout(() => {
                    const cursor = document.querySelector('.typed-cursor');
                    if (cursor) {
                        cursor.remove(); // 直接移除光标元素
                    }
                }, 500); // 0.5秒后移除光标
            }
        });
    }
    
    // 头部滚动效果
    const header = document.querySelector('.header');
    if (header) {
        window.addEventListener('scroll', function() {
            if (window.scrollY > 50) {
                header.classList.add('scrolled');
            } else {
                header.classList.remove('scrolled');
            }
        });
    }
    
    // 设置活跃导航链接
    const currentPage = window.location.pathname;
    const navLinks = document.querySelectorAll('.nav-link');
    
    navLinks.forEach(link => {
        const href = link.getAttribute('href');
        if (href === currentPage || (currentPage === '/' && href === '/')) {
            link.classList.add('active');
        }
    });
    
    // 为所有链接添加点击反馈
    const allLinks = document.querySelectorAll('a');
    allLinks.forEach(link => {
        link.addEventListener('click', function() {
            // 添加点击反馈效果
            this.style.transform = 'scale(0.95)';
            setTimeout(() => {
                this.style.transform = '';
            }, 150);
        });
    });
    
    // 平滑滚动效果
    const smoothScrollLinks = document.querySelectorAll('a[href^="#"]');
    smoothScrollLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            const targetId = this.getAttribute('href').substring(1);
            const targetElement = document.getElementById(targetId);
            if (targetElement) {
                targetElement.scrollIntoView({
                    behavior: 'smooth'
                });
            }
        });
    });
});
