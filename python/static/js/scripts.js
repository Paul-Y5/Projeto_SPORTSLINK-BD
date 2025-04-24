// Exibe o indicador de carregamento para login
function showLoginLoading() {
    document.getElementById("login_loading").style.display = "block";
}

// Exibe o indicador de carregamento para registro
function showRegisterLoading() {
    document.getElementById("register_loading").style.display = "block";
}

// Configura os indicadores de carregamento para requisições HTMX
document.addEventListener("htmx:configRequest", (event) => {
    let indicatorSelector = event.detail.indicator;

    if (!indicatorSelector) {
        const form = event.target.closest("form");
        if (form) {
            if (form.getAttribute("hx-post") === "/register") {
                indicatorSelector = "#register_loading";
            } else if (form.getAttribute("hx-post") === "/login") {
                indicatorSelector = "#login_loading";
            }
        }
    }

    const indicator = document.querySelector(indicatorSelector);
    if (indicator) {
        indicator.style.display = "block";
    } else {
        console.error("Indicador não encontrado. Verifique o seletor:", indicatorSelector);
    }
});

// Oculta os indicadores de carregamento após a requisição HTMX
document.addEventListener("htmx:afterRequest", (event) => {
    let indicatorSelector = event.detail.indicator;

    if (!indicatorSelector) {
        const form = event.target.closest("form");
        if (form) {
            if (form.getAttribute("hx-post") === "/register") {
                indicatorSelector = "#register_loading";
            } else if (form.getAttribute("hx-post") === "/login") {
                indicatorSelector = "#login_loading";
            }
        }
    }

    const indicator = document.querySelector(indicatorSelector);
    if (indicator) {
        indicator.style.display = "none";
    } else {
        console.warn("Indicador não encontrado para ocultar:", indicatorSelector);
    }
});

document.addEventListener("DOMContentLoaded", function () {
  document.body.addEventListener("htmx:afterSwap", function (event) {
    if (
      event.target.id === "login_result" ||
      event.target.id === "register_result"
    ) {
      const form = document.querySelector(
        `form[hx-target="#${event.target.id}"]`
      );
      if (form) {
        form.reset();
      } else {
        console.warn("Formulário não encontrado para o alvo:", event.target.id);
      }
    }
  });
});

// Função para dar tempo e fechar flash messages
function closeFlashMessages() {
    const flashMessages = document.querySelectorAll(".flash-message");
    flashMessages.forEach((message) => {
        setTimeout(() => {
            message.style.display = "none";
        }, 5000); // Adjusted to use class selector for multiple flash messages
    });
}

document.addEventListener("DOMContentLoaded", closeFlashMessages);

// Admin Dashboard Functions
// Função para filtrar a tabela com base no texto digitado
function filterTable() {
    const filterValue = document.getElementById("filterInput").value.toLowerCase();
    const rows = document.querySelectorAll("#usersTable tbody tr");

    rows.forEach(row => {
        const cells = Array.from(row.querySelectorAll("td"));
        const matches = cells.some(cell => cell.textContent.toLowerCase().includes(filterValue));
        row.style.display = matches ? "" : "none";
    });
}


// Função para filtrar a tabela por tipo de utilizador
function filterByUserType() {
    const userType = document.getElementById("userTypeSelect").value; 
    const rows = document.querySelectorAll("#usersTable tbody tr"); 

    rows.forEach(row => {
        const userTypeCell = row.querySelector(".user-type").textContent;
        if (userType === "todos" ) {
            row.style.display = ""; // Exibe todas as linhas
        } else if (userType === userTypeCell) {
            row.style.display = ""; // Exibe a linha se o tipo de utilizador corresponder
        } else {
            row.style.display = "none";
        }
    });
}

// Função para ordenar a tabela com base na coluna selecionada
function sortTable() {
    const table = document.getElementById("usersTable");
    const rows = Array.from(table.querySelectorAll("tbody tr"));
    const sortBy = document.getElementById("orderSelect").value;

    const columnIndex = {
        "ID": 0,
        "Nome": 1,
        "Email": 2,
        "Telefone": 3,
        "Nacionalidade": 4,
        "Idade": 5,
        "Descrição": 6,
        "IBAN": 7,
        "Número de Campos": 8
    }[sortBy];

    const sortedRows = rows.sort((a, b) => {
        const cellA = a.cells[columnIndex].textContent.trim();
        const cellB = b.cells[columnIndex].textContent.trim();

        if (!isNaN(cellA) && !isNaN(cellB)) {
            return Number(cellA) - Number(cellB); // Numeric sorting
        }
        return cellA.localeCompare(cellB); // Alphabetical sorting
    });

    const tbody = table.querySelector("tbody");
    tbody.innerHTML = "";
    sortedRows.forEach(row => tbody.appendChild(row));
}

// Motor de busca para a tabela de campos
function filterFieldsTable() {
    const filterValue = document.getElementById("filterFieldsInput").value.toLowerCase();
    const rows = document.querySelectorAll("#fieldsTable tbody tr");

    rows.forEach(row => {
        const cells = Array.from(row.querySelectorAll("td"));
        const matches = cells.some(cell => cell.textContent.toLowerCase().includes(filterValue));
        row.style.display = matches ? "" : "none";
    });
}

// Ordenar a tabela de campos
function sortFieldsTable() {
    const table = document.getElementById("fieldsTable");
    const rows = Array.from(table.querySelectorAll("tbody tr"));
    const sortBy = document.getElementById("orderFieldsSelect").value;

    const columnIndex = {
        "ID": 0,
        "Nome": 1,
        "Comprimento": 2,
        "Largura": 3,
        "Ocupado": 4
    }[sortBy];

    const sortedRows = rows.sort((a, b) => {
        const cellA = a.cells[columnIndex].textContent.trim();
        const cellB = b.cells[columnIndex].textContent.trim();

        if (!isNaN(cellA) && !isNaN(cellB)) {
            return Number(cellA) - Number(cellB); // Numeric sorting
        }
        return cellA.localeCompare(cellB); // Alphabetical sorting
    });

    const tbody = table.querySelector("tbody");
    tbody.innerHTML = "";
    sortedRows.forEach(row => tbody.appendChild(row));
}

// Filtrar por tipo de campo (ocupado ou não)
function filterByFieldType() {
    const fieldType = document.getElementById("fieldTypeSelect").value;
    const rows = document.querySelectorAll("#fieldsTable tbody tr");

    rows.forEach(row => {
        const fieldTypeCell = row.querySelector("td:nth-child(5)").textContent.trim();
        if (fieldType === "todos" || fieldType === fieldTypeCell) {
            row.style.display = "";
        } else {
            row.style.display = "none";
        }
    });
}


// Função para exibir a tabela correspondente ao link clicado na navbar
function showTable(tableId) {
    const tables = document.querySelectorAll('.table-container');
    tables.forEach(table => {
        table.style.display = 'none';
    });

    document.getElementById(tableId).style.display = 'block';

    // Atualiza a navbar para indicar o ativo
    const navLinks = document.querySelectorAll('.navbar-nav .nav-link');
    navLinks.forEach(link => link.classList.remove('active'));

    const activeLink = Array.from(navLinks).find(link => link.getAttribute('onclick')?.includes(tableId));
    if (activeLink) {
        activeLink.classList.add('active');
    }
}


