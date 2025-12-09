const State = {
    isOpen: false,
    options: [],
    position: { x: 0, y: 0 },
    scale: 1.0,
    activeSubmenu: null,
    activeSubmenu2: null,
    hoveredItem: null,
    hoveredSubmenuItem: null,
    submenuTimeout: null,
    submenu2Timeout: null,
    submenuCloseTimeout: null,
    submenu2CloseTimeout: null,
    isClosing: false,
    isInSubmenu: false,
    isInSubmenu2: false,
    currentSubmenuItems: [],
    currentSubmenu2Items: []
};

const Elements = {
    menu: document.getElementById('context-menu'),
    menuItems: document.getElementById('menu-items'),
    submenu: document.getElementById('submenu'),
    submenuItems: document.getElementById('submenu-items'),
    submenu2: document.getElementById('submenu2'),
    submenu2Items: document.getElementById('submenu2-items')
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
    
    buildMenuItems(options, Elements.menuItems, 0);
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
    
    clearAllTimeouts();
    closeSubmenu2(true);
    closeSubmenu(true);
    
    Elements.menu.classList.remove('visible');
    Elements.menu.classList.add('animate-out');
    
    setTimeout(() => {
        Elements.menu.classList.add('hidden');
        Elements.menu.classList.remove('animate-out');
        Elements.menu.style.display = 'none';
        Elements.menuItems.innerHTML = '';
        State.isClosing = false;
        State.hoveredItem = null;
        State.hoveredSubmenuItem = null;
    }, 120);
    
    if (sendCallback) {
        fetch('https://nbl-target/close', {
            method: 'POST',
            body: JSON.stringify({})
        });
    }
}

function clearAllTimeouts() {
    if (State.submenuTimeout) {
        clearTimeout(State.submenuTimeout);
        State.submenuTimeout = null;
    }
    if (State.submenu2Timeout) {
        clearTimeout(State.submenu2Timeout);
        State.submenu2Timeout = null;
    }
    if (State.submenuCloseTimeout) {
        clearTimeout(State.submenuCloseTimeout);
        State.submenuCloseTimeout = null;
    }
    if (State.submenu2CloseTimeout) {
        clearTimeout(State.submenu2CloseTimeout);
        State.submenu2CloseTimeout = null;
    }
}

function refreshMenu(options) {
    if (!State.isOpen) return;
    
    if (!options || options.length === 0) {
        closeMenu();
        return;
    }
    
    State.options = options;
    
    if (State.isInSubmenu || State.isInSubmenu2 || State.activeSubmenu || State.activeSubmenu2) {
        updateCheckboxStates(options, Elements.menuItems);
        updateSubmenuCheckboxes(options);
        updateSubmenu2Checkboxes(options);
    } else {
        updateMenuItems(options, Elements.menuItems);
    }
}

function updateMenuItems(options, container) {
    const existingItems = container.querySelectorAll('.menu-item');
    
    if (existingItems.length !== options.length) {
        buildMenuItems(options, container, 0);
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
    
    State.currentSubmenuItems = parentOption.items;
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

function updateSubmenu2Checkboxes(mainOptions) {
    if (!State.activeSubmenu || !State.activeSubmenu2) return;
    
    const parentIndex = parseInt(State.activeSubmenu.dataset.index);
    const parentOption = mainOptions[parentIndex];
    
    if (!parentOption || !parentOption.items) return;
    
    const subParentIndex = parseInt(State.activeSubmenu2.dataset.index);
    const subParentOption = parentOption.items[subParentIndex];
    
    if (!subParentOption || !subParentOption.items) return;
    
    State.currentSubmenu2Items = subParentOption.items;
    const submenu2Items = Elements.submenu2Items.querySelectorAll('.menu-item');
    
    subParentOption.items.forEach((subOption, index) => {
        const item = submenu2Items[index];
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

function buildMenuItems(options, container, level) {
    container.innerHTML = '';
    
    options.forEach((option, index) => {
        const item = document.createElement('div');
        item.className = 'menu-item';
        item.dataset.id = option.id;
        item.dataset.index = index;
        item.dataset.level = level;
        
        const hasSubmenu = option.items && option.items.length > 0;
        const hasCheckbox = option.checkbox === true;
        
        if (hasSubmenu && !hasCheckbox && level < 2) {
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
        
        if (hasSubmenu && !hasCheckbox && level < 2) {
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
                handleItemClick(option, item, level);
            }
        });
        
        item.addEventListener('mouseenter', () => handleItemHover(option, item, level));
        
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
    closeSubmenu2(true);
    
    State.activeSubmenu = parentItem;
    State.isInSubmenu = true;
    State.currentSubmenuItems = items;
    
    fetch('https://nbl-target/submenuOpen', {
        method: 'POST',
        body: JSON.stringify({})
    });
    
    buildMenuItems(items, Elements.submenuItems, 1);
    
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
    
    if (y + items.length * 36 > window.innerHeight - 10) {
        y = window.innerHeight - items.length * 36 - 10;
    }
    
    if (y < 10) {
        y = 10;
    }
    
    Elements.submenu.style.left = `${x}px`;
    Elements.submenu.style.top = `${y}px`;
    
    Elements.submenu.style.display = 'block';
    Elements.submenu.classList.remove('hidden');
    requestAnimationFrame(() => {
        Elements.submenu.classList.add('visible');
    });
}

function openSubmenu2(items, parentItem) {
    State.activeSubmenu2 = parentItem;
    State.isInSubmenu2 = true;
    State.currentSubmenu2Items = items;
    
    buildMenuItems(items, Elements.submenu2Items, 2);
    
    const parentRect = parentItem.getBoundingClientRect();
    const submenuRect = Elements.submenu.getBoundingClientRect();
    
    let x = submenuRect.right + 5;
    let y = parentRect.top;
    
    const submenuWidth = 220;
    if (x + submenuWidth > window.innerWidth - 10) {
        x = submenuRect.left - submenuWidth - 5;
        Elements.submenu2.classList.add('left');
    } else {
        Elements.submenu2.classList.remove('left');
    }
    
    if (y + items.length * 36 > window.innerHeight - 10) {
        y = window.innerHeight - items.length * 36 - 10;
    }
    
    if (y < 10) {
        y = 10;
    }
    
    Elements.submenu2.style.left = `${x}px`;
    Elements.submenu2.style.top = `${y}px`;
    
    Elements.submenu2.style.display = 'block';
    Elements.submenu2.classList.remove('hidden');
    requestAnimationFrame(() => {
        Elements.submenu2.classList.add('visible');
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
    
    closeSubmenu2(true);
    
    if (immediate) {
        State.activeSubmenu = null;
        State.isInSubmenu = false;
        State.currentSubmenuItems = [];
        State.hoveredSubmenuItem = null;
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

function closeSubmenu2(immediate = false) {
    if (State.submenu2Timeout) {
        clearTimeout(State.submenu2Timeout);
        State.submenu2Timeout = null;
    }
    
    if (State.submenu2CloseTimeout) {
        clearTimeout(State.submenu2CloseTimeout);
        State.submenu2CloseTimeout = null;
    }
    
    if (immediate) {
        State.activeSubmenu2 = null;
        State.isInSubmenu2 = false;
        State.currentSubmenu2Items = [];
        Elements.submenu2.classList.remove('visible');
        Elements.submenu2.classList.add('hidden');
        Elements.submenu2.style.display = 'none';
        Elements.submenu2Items.innerHTML = '';
    }
}

function handleItemClick(option, itemElement, level) {
    if (option.items && option.items.length > 0 && level < 2) {
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

function handleItemHover(option, item, level) {
    if (level === 0) {
        if (State.submenuTimeout) {
            clearTimeout(State.submenuTimeout);
            State.submenuTimeout = null;
        }
        if (State.submenuCloseTimeout) {
            clearTimeout(State.submenuCloseTimeout);
            State.submenuCloseTimeout = null;
        }
        
        State.hoveredItem = item;
        
        if (State.activeSubmenu && State.activeSubmenu !== item) {
            closeSubmenu(true);
        }
        
        if (option.items && option.items.length > 0) {
            State.submenuTimeout = setTimeout(() => {
                openSubmenu(option.items, item);
            }, 100);
        }
    } else if (level === 1) {
        if (State.submenu2Timeout) {
            clearTimeout(State.submenu2Timeout);
            State.submenu2Timeout = null;
        }
        if (State.submenu2CloseTimeout) {
            clearTimeout(State.submenu2CloseTimeout);
            State.submenu2CloseTimeout = null;
        }
        
        State.hoveredSubmenuItem = item;
        
        if (State.activeSubmenu2 && State.activeSubmenu2 !== item) {
            closeSubmenu2(true);
        }
        
        if (option.items && option.items.length > 0) {
            State.submenu2Timeout = setTimeout(() => {
                openSubmenu2(option.items, item);
            }, 100);
        }
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
    const clickedSubmenu2 = Elements.submenu2.contains(event.target);
    
    if (event.button === 2) {
        event.preventDefault();
        closeMenu();
        return;
    }
    
    if (event.button === 0 && !clickedMenu && !clickedSubmenu && !clickedSubmenu2) {
        closeMenu();
    }
});

document.addEventListener('contextmenu', (event) => {
    event.preventDefault();
});

Elements.menu.addEventListener('mouseleave', () => {
    if (State.submenuTimeout) {
        clearTimeout(State.submenuTimeout);
        State.submenuTimeout = null;
    }
    
    if (!State.isInSubmenu && !State.isInSubmenu2) {
        State.submenuCloseTimeout = setTimeout(() => {
            if (!State.isInSubmenu && !State.isInSubmenu2) {
                closeSubmenu(true);
            }
        }, 100);
    }
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
    
    if (State.submenu2Timeout) {
        clearTimeout(State.submenu2Timeout);
        State.submenu2Timeout = null;
    }
    
    if (!State.isInSubmenu2) {
        State.submenu2CloseTimeout = setTimeout(() => {
            if (!State.isInSubmenu2) {
                closeSubmenu2(true);
            }
        }, 100);
        
        State.submenuCloseTimeout = setTimeout(() => {
            if (!State.isInSubmenu && !State.isInSubmenu2) {
                closeSubmenu(true);
            }
        }, 150);
    }
});

Elements.submenu2.addEventListener('mouseenter', () => {
    State.isInSubmenu2 = true;
    if (State.submenu2CloseTimeout) {
        clearTimeout(State.submenu2CloseTimeout);
        State.submenu2CloseTimeout = null;
    }
    if (State.submenuCloseTimeout) {
        clearTimeout(State.submenuCloseTimeout);
        State.submenuCloseTimeout = null;
    }
});

Elements.submenu2.addEventListener('mouseleave', () => {
    State.isInSubmenu2 = false;
    
    State.submenu2CloseTimeout = setTimeout(() => {
        if (!State.isInSubmenu2) {
            closeSubmenu2(true);
        }
    }, 100);
});
