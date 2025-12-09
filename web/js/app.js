const State = {
    isOpen: false,
    options: [],
    position: { x: 0, y: 0 },
    scale: 1.0,
    activeSubmenu: null,
    submenuTimeout: null,
    submenuCloseTimeout: null,
    isClosing: false,
    isInSubmenu: false
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
            closeMenu(false);
            break;
            
        case 'refresh':
            refreshMenu(data.options);
            break;
    }
});

function openMenu(options, position, scale = 1.0) {
    if (!options || options.length === 0) return;
    if (State.isClosing) return;
    
    State.isOpen = true;
    State.options = options;
    State.position = position;
    State.scale = scale;
    
    buildMenuItems(options, Elements.menuItems);
    positionMenu(Elements.menu, position.x, position.y);
    
    if (scale !== 1.0) {
        Elements.menu.setAttribute('data-scale', scale.toString());
    }
    
    Elements.menu.style.display = 'block';
    Elements.menu.classList.remove('hidden');
    
    requestAnimationFrame(() => {
        Elements.menu.classList.add('visible');
    });
}

function closeMenu(sendCallback = true) {
    if (!State.isOpen || State.isClosing) return;
    
    State.isOpen = false;
    State.isClosing = true;
    
    closeSubmenu(true);
    
    Elements.menu.classList.remove('visible');
    Elements.menu.classList.add('animate-out');
    
    setTimeout(() => {
        Elements.menu.classList.add('hidden');
        Elements.menu.classList.remove('animate-out');
        Elements.menu.style.display = 'none';
        Elements.menuItems.innerHTML = '';
        State.isClosing = false;
    }, 120);
    
    if (sendCallback) {
        fetch('https://nbl-target/close', {
            method: 'POST',
            body: JSON.stringify({})
        });
    }
}

function refreshMenu(options) {
    if (!State.isOpen) return;
    
    if (!options || options.length === 0) {
        closeMenu();
        return;
    }
    
    const oldOptions = State.options;
    State.options = options;
    
    if (State.isInSubmenu || State.activeSubmenu) {
        updateCheckboxStates(options, Elements.menuItems);
        updateSubmenuCheckboxes(options);
    } else {
        updateMenuItems(options, Elements.menuItems);
    }
}

function updateMenuItems(options, container) {
    const existingItems = container.querySelectorAll('.menu-item');
    
    if (existingItems.length !== options.length) {
        buildMenuItems(options, container);
        return;
    }
    
    options.forEach((option, index) => {
        const item = existingItems[index];
        if (!item) return;
        
        const checkbox = item.querySelector('.item-checkbox');
        if (checkbox && option.checkbox) {
            if (option.checked) {
                checkbox.classList.add('checked');
            } else {
                checkbox.classList.remove('checked');
            }
        }
        
        const label = item.querySelector('.item-label');
        if (label && label.textContent !== option.label) {
            label.textContent = option.label;
        }
    });
}

function updateCheckboxStates(options, container) {
    const existingItems = container.querySelectorAll('.menu-item');
    
    options.forEach((option, index) => {
        const item = existingItems[index];
        if (!item) return;
        
        const checkbox = item.querySelector('.item-checkbox');
        if (checkbox && option.checkbox) {
            if (option.checked) {
                checkbox.classList.add('checked');
            } else {
                checkbox.classList.remove('checked');
            }
        }
    });
}

function updateSubmenuCheckboxes(mainOptions) {
    if (!State.activeSubmenu) return;
    
    const parentIndex = parseInt(State.activeSubmenu.dataset.index);
    const parentOption = mainOptions[parentIndex];
    
    if (!parentOption || !parentOption.items) return;
    
    const submenuItems = Elements.submenuItems.querySelectorAll('.menu-item');
    
    parentOption.items.forEach((subOption, index) => {
        const item = submenuItems[index];
        if (!item) return;
        
        const checkbox = item.querySelector('.item-checkbox');
        if (checkbox && subOption.checkbox) {
            if (subOption.checked) {
                checkbox.classList.add('checked');
            } else {
                checkbox.classList.remove('checked');
            }
        }
    });
}

function buildMenuItems(options, container) {
    container.innerHTML = '';
    
    options.forEach((option, index) => {
        const item = document.createElement('div');
        item.className = 'menu-item';
        item.dataset.id = option.id;
        item.dataset.index = index;
        
        const hasSubmenu = option.items && option.items.length > 0;
        const hasCheckbox = option.checkbox === true;
        
        if (hasSubmenu && !hasCheckbox) {
            item.classList.add('has-submenu');
        }
        
        if (hasCheckbox) {
            item.classList.add('has-checkbox');
        }
        
        const icon = document.createElement('div');
        icon.className = 'item-icon';
        icon.innerHTML = `<i class="${option.icon || 'fas fa-hand-pointer'}"></i>`;
        
        const label = document.createElement('div');
        label.className = 'item-label';
        label.textContent = option.label || 'Interact';
        
        item.appendChild(icon);
        item.appendChild(label);
        
        if (hasSubmenu && !hasCheckbox) {
            const arrow = document.createElement('div');
            arrow.className = 'submenu-arrow';
            arrow.innerHTML = '<i class="fas fa-chevron-right"></i>';
            item.appendChild(arrow);
        }
        
        if (hasCheckbox) {
            const checkbox = document.createElement('div');
            checkbox.className = 'item-checkbox';
            if (option.checked) {
                checkbox.classList.add('checked');
            }
            item.appendChild(checkbox);
        }
        
        item.addEventListener('click', (e) => {
            e.stopPropagation();
            if (hasCheckbox) {
                handleCheckboxClick(option, item);
            } else {
                handleItemClick(option, item);
            }
        });
        
        if (!hasCheckbox) {
            item.addEventListener('mouseenter', () => handleItemHover(option, item));
            item.addEventListener('mouseleave', () => handleItemLeave(option));
        }
        
        container.appendChild(item);
    });
}

function positionMenu(menu, x, y) {
    const windowWidth = window.innerWidth;
    const windowHeight = window.innerHeight;
    
    const menuWidth = 220;
    const menuHeight = Math.min(State.options.length * 36 + 8, 450);
    
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
    State.isInSubmenu = true;
    
    fetch('https://nbl-target/submenuOpen', {
        method: 'POST',
        body: JSON.stringify({})
    });
    
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
    
    Elements.submenu.style.display = 'block';
    Elements.submenu.classList.remove('hidden');
    requestAnimationFrame(() => {
        Elements.submenu.classList.add('visible');
    });
}

function closeSubmenu(immediate = false) {
    if (State.submenuTimeout) {
        clearTimeout(State.submenuTimeout);
        State.submenuTimeout = null;
    }
    
    if (State.submenuCloseTimeout) {
        clearTimeout(State.submenuCloseTimeout);
        State.submenuCloseTimeout = null;
    }
    
    const wasOpen = State.activeSubmenu !== null;
    
    if (immediate) {
        State.activeSubmenu = null;
        State.isInSubmenu = false;
        Elements.submenu.classList.remove('visible');
        Elements.submenu.classList.add('hidden');
        Elements.submenu.style.display = 'none';
        Elements.submenuItems.innerHTML = '';
        
        if (wasOpen) {
            fetch('https://nbl-target/submenuClose', {
                method: 'POST',
                body: JSON.stringify({})
            });
        }
    }
}

function scheduleSubmenuClose() {
    if (State.submenuCloseTimeout) {
        clearTimeout(State.submenuCloseTimeout);
    }
    
    State.submenuCloseTimeout = setTimeout(() => {
        if (!State.isInSubmenu) {
            closeSubmenu(true);
        }
    }, 150);
}

function handleItemClick(option, itemElement) {
    if (option.items && option.items.length > 0) {
        return;
    }
    
    itemElement.classList.add('clicked');
    
    setTimeout(() => {
        fetch('https://nbl-target/select', {
            method: 'POST',
            body: JSON.stringify({
                id: option.id,
                name: option.name,
                label: option.label,
                shouldClose: option.shouldClose || false
            })
        });
    }, 50);
}

function handleCheckboxClick(option, itemElement) {
    const checkbox = itemElement.querySelector('.item-checkbox');
    const newState = !option.checked;
    
    option.checked = newState;
    
    if (newState) {
        checkbox.classList.add('checked');
    } else {
        checkbox.classList.remove('checked');
    }
    
    fetch('https://nbl-target/check', {
        method: 'POST',
        body: JSON.stringify({
            id: option.id,
            name: option.name,
            label: option.label,
            checked: newState
        })
    });
}

function handleItemHover(option, item) {
    if (State.submenuTimeout) {
        clearTimeout(State.submenuTimeout);
    }
    
    if (State.submenuCloseTimeout) {
        clearTimeout(State.submenuCloseTimeout);
        State.submenuCloseTimeout = null;
    }
    
    if (option.items && option.items.length > 0) {
        State.submenuTimeout = setTimeout(() => {
            openSubmenu(option.items, item);
        }, 150);
    } else if (State.activeSubmenu && State.activeSubmenu !== item) {
        scheduleSubmenuClose();
    }
}

function handleItemLeave(option) {
    if (option.items && option.items.length > 0) {
        scheduleSubmenuClose();
    }
}

document.addEventListener('keydown', (event) => {
    if (!State.isOpen) return;
    
    if (event.key === 'Escape') {
        closeMenu();
    }
});

document.addEventListener('mousedown', (event) => {
    if (!State.isOpen) return;
    
    const clickedMenu = Elements.menu.contains(event.target);
    const clickedSubmenu = Elements.submenu.contains(event.target);
    
    if (event.button === 2) {
        event.preventDefault();
        closeMenu();
        return;
    }
    
    if (event.button === 0 && !clickedMenu && !clickedSubmenu) {
        closeMenu();
    }
});

document.addEventListener('contextmenu', (event) => {
    event.preventDefault();
});

Elements.submenu.addEventListener('mouseenter', () => {
    State.isInSubmenu = true;
    if (State.submenuCloseTimeout) {
        clearTimeout(State.submenuCloseTimeout);
        State.submenuCloseTimeout = null;
    }
});

Elements.submenu.addEventListener('mouseleave', () => {
    State.isInSubmenu = false;
    scheduleSubmenuClose();
});
