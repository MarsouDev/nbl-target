const State = {
    isOpen: false,
    options: [],
    position: { x: 0, y: 0 },
    scale: 1.0,
    activeSubmenu: null,
    submenuTimeout: null
};

const Elements = {
    menu: document.getElementById('context-menu'),
    menuItems: document.getElementById('menu-items'),
    submenu: document.getElementById('submenu'),
    submenuItems: document.getElementById('submenu-items')
};

window.addEventListener('message', (event) => {
    const data = event.data;
    
    switch (data.action) {
        case 'open':
            openMenu(data.options, data.position, data.scale);
            break;
            
        case 'close':
            closeMenu();
            break;
    }
});

function openMenu(options, position, scale = 1.0) {
    if (!options || options.length === 0) return;
    
    State.isOpen = true;
    State.options = options;
    State.position = position;
    State.scale = scale;
    
    buildMenuItems(options, Elements.menuItems);
    
    positionMenu(Elements.menu, position.x, position.y);
    
    if (scale !== 1.0) {
        Elements.menu.setAttribute('data-scale', scale.toString());
    }
    
    Elements.menu.classList.remove('hidden');
    requestAnimationFrame(() => {
        Elements.menu.classList.add('visible');
    });
}

function closeMenu() {
    if (!State.isOpen) return;
    
    State.isOpen = false;
    
    closeSubmenu();
    
    Elements.menu.classList.remove('visible');
    Elements.menu.classList.add('animate-out');
    
    setTimeout(() => {
        Elements.menu.classList.add('hidden');
        Elements.menu.classList.remove('animate-out');
        Elements.menuItems.innerHTML = '';
    }, 150);
    
    fetch('https://nbl-contextmenu/close', {
        method: 'POST',
        body: JSON.stringify({})
    });
}

function buildMenuItems(options, container) {
    container.innerHTML = '';
    
    options.forEach((option, index) => {
        const item = document.createElement('div');
        item.className = 'menu-item';
        item.dataset.id = option.id;
        item.dataset.index = index;
        
        if (option.items && option.items.length > 0) {
            item.classList.add('has-submenu');
        }
        
        const icon = document.createElement('div');
        icon.className = 'item-icon';
        icon.innerHTML = `<i class="${option.icon || 'fas fa-hand-pointer'}"></i>`;
        
        const label = document.createElement('div');
        label.className = 'item-label';
        label.textContent = option.label || 'Interact';
        
        item.appendChild(icon);
        item.appendChild(label);
        
        if (option.items && option.items.length > 0) {
            const arrow = document.createElement('div');
            arrow.className = 'submenu-arrow';
            arrow.innerHTML = '<i class="fas fa-chevron-right"></i>';
            item.appendChild(arrow);
        }
        
        item.addEventListener('click', () => handleItemClick(option));
        item.addEventListener('mouseenter', () => handleItemHover(option, item));
        item.addEventListener('mouseleave', () => handleItemLeave(option));
        
        container.appendChild(item);
    });
}

function positionMenu(menu, x, y) {
    const menuRect = menu.getBoundingClientRect();
    const windowWidth = window.innerWidth;
    const windowHeight = window.innerHeight;
    
    const menuWidth = 220;
    const menuHeight = Math.min(State.options.length * 40 + 12, 400);
    
    let finalX = x;
    let finalY = y;
    
    if (x + menuWidth > windowWidth - 10) {
        finalX = x - menuWidth;
    }
    
    if (y + menuHeight > windowHeight - 10) {
        finalY = windowHeight - menuHeight - 10;
    }
    
    if (finalX < 10) {
        finalX = 10;
    }
    
    if (finalY < 10) {
        finalY = 10;
    }
    
    menu.style.left = `${finalX}px`;
    menu.style.top = `${finalY}px`;
}

function openSubmenu(items, parentItem) {
    State.activeSubmenu = parentItem;
    
    buildMenuItems(items, Elements.submenuItems);
    
    const parentRect = parentItem.getBoundingClientRect();
    const menuRect = Elements.menu.getBoundingClientRect();
    
    let x = menuRect.right + 5;
    let y = parentRect.top;
    
    const submenuWidth = 220;
    if (x + submenuWidth > window.innerWidth - 10) {
        x = menuRect.left - submenuWidth - 5;
        Elements.submenu.classList.add('left');
    } else {
        Elements.submenu.classList.remove('left');
    }
    
    Elements.submenu.style.left = `${x}px`;
    Elements.submenu.style.top = `${y}px`;
    
    Elements.submenu.classList.remove('hidden');
    requestAnimationFrame(() => {
        Elements.submenu.classList.add('visible');
    });
}

function closeSubmenu() {
    if (State.submenuTimeout) {
        clearTimeout(State.submenuTimeout);
        State.submenuTimeout = null;
    }
    
    State.activeSubmenu = null;
    
    Elements.submenu.classList.remove('visible');
    Elements.submenu.classList.add('hidden');
    Elements.submenuItems.innerHTML = '';
}

function handleItemClick(option) {
    if (option.items && option.items.length > 0) {
        return;
    }
    
    fetch('https://nbl-contextmenu/select', {
        method: 'POST',
        body: JSON.stringify({
            id: option.id,
            name: option.name,
            label: option.label
        })
    });
    
    closeMenu();
}

function handleItemHover(option, item) {
    if (State.submenuTimeout) {
        clearTimeout(State.submenuTimeout);
    }
    
    if (option.items && option.items.length > 0) {
        State.submenuTimeout = setTimeout(() => {
            openSubmenu(option.items, item);
        }, 150);
    } else {
        closeSubmenu();
    }
}

function handleItemLeave(option) {
}

document.addEventListener('keydown', (event) => {
    if (!State.isOpen) return;
    
    switch (event.key) {
        case 'Escape':
            closeMenu();
            break;
    }
});

document.addEventListener('click', (event) => {
    if (!State.isOpen) return;
    
    const clickedMenu = Elements.menu.contains(event.target);
    const clickedSubmenu = Elements.submenu.contains(event.target);
    
    if (!clickedMenu && !clickedSubmenu) {
        closeMenu();
    }
});

document.addEventListener('contextmenu', (event) => {
    event.preventDefault();
});
