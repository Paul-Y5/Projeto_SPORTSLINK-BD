// Função para mostrar o indicador de carregamento
function showLoadingIndicator(indicatorId) {
  const indicator = document.getElementById(indicatorId);
  if (indicator) {
    indicator.style.display = "block";
  } else {
    console.error(
      `Indicador de carregamento não encontrado: ${indicatorId}`
    );
  }
}

// Função para ocultar o indicador de carregamento
function hideLoadingIndicator(indicatorId) {
  const indicator = document.getElementById(indicatorId);
  if (indicator) {
    indicator.style.display = "none";
  } else {
    console.warn(
      `Indicador de carregamento não encontrado para ocultar: ${indicatorId}`
    );
  }
}

// Configura os indicadores de carregamento para as requisições HTMX
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

  showLoadingIndicator(indicatorSelector);
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

  hideLoadingIndicator(indicatorSelector);
});

// Restaura o formulário após a troca de conteúdo
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
        console.error("Formulário não encontrado para o alvo:", event.target.id);
      }
    }
  });
});

// Função para fechar mensagens flash após 5 segundos
function closeFlashMessages() {
  const flashMessages = document.querySelectorAll(".flash-message");
  flashMessages.forEach((message) => {
    setTimeout(() => {
      message.style.display = "none";
    }, 5000); // Tempo ajustado para 5 segundos
  });
}

document.addEventListener("DOMContentLoaded", closeFlashMessages);

// Admin Dashboard Functions

// Função para exibir a tabela correspondente ao link clicado na navbar
function showTable(tableId) {
  const tables = document.querySelectorAll(".table-container");
  tables.forEach((table) => (table.style.display = "none"));

  const tableToShow = document.getElementById(tableId);
  if (tableToShow) {
    tableToShow.style.display = "block";
  }

  // Atualiza a navbar para indicar o ativo
  const navLinks = document.querySelectorAll(".navbar-nav .nav-link");
  navLinks.forEach((link) => link.classList.remove("active"));

  const activeLink = Array.from(navLinks).find((link) =>
    link.getAttribute("onclick")?.includes(tableId)
  );
  if (activeLink) {
    activeLink.classList.add("active");
  }
}

// Alterna entre links ativos na navbar
document.addEventListener("DOMContentLoaded", function () {
  const navLinks = document.querySelectorAll(".navbar-nav .nav-link");

  navLinks.forEach((link) => {
    link.addEventListener("click", function () {
      navLinks.forEach((nav) => nav.classList.remove("active"));
      this.classList.add("active");
    });
  });
});

// Função para aplicar filtros de utilizadores
function applyUserFilters() {
  const search = document.getElementById("filterInput").value;
  const userType = document.getElementById("userTypeSelect").value;

  const url = new URL(window.location.href);
  if (search) url.searchParams.set("user_search", search);
  if (userType) url.searchParams.set("user_type", userType);
  window.location.href = url.toString();
}

// Função para aplicar filtros de campos
function applyFieldFilters() {
  const search = document.getElementById("filterFieldsInput").value;
  const fieldType = document.getElementById("fieldTypeSelect").value;

  const url = new URL(window.location.href);
  if (search) url.searchParams.set("field_search", search);
  if (fieldType) url.searchParams.set("field_type", fieldType);
  window.location.href = url.toString();
}

// Ordenar Utilizadores
function applyUserOrdering() {
  const order = document.getElementById("orderSelect");
  const direction = document.getElementById("directionSelect");

  if (order && direction) {
    const orderValue = order.value;
    const directionValue = direction.value;

    const url = new URL(window.location.href);
    url.searchParams.set("user_order", orderValue);
    url.searchParams.set("user_direction", directionValue);
    window.location.href = url.toString();
  } else {
    console.error("Elementos de ordenação não encontrados");
  }
}

// Ordenar Campos
function applyFieldOrdering() {
  const order = document.getElementById("orderFieldsSelect");
  const direction = document.getElementById("directionFieldsSelect");

  if (order && direction) {
    const orderValue = order.value;
    const directionValue = direction.value;

    const url = new URL(window.location.href);
    url.searchParams.set("field_order", orderValue);
    url.searchParams.set("field_direction", directionValue);
    window.location.href = url.toString();
  } else {
    console.error("Elementos de ordenação não encontrados");
  }
}

// Ordenar Partidas
function applyMatchOrdering() {
  const order = document.getElementById("orderMatchesSelect");
  const direction = document.getElementById("directionMatchesSelect");

  if (order && direction) {
    const orderValue = order.value;
    const directionValue = direction.value;

    const url = new URL(window.location.href);
    url.searchParams.set("match_order", orderValue);
    url.searchParams.set("match_direction", directionValue);
    window.location.href = url.toString();
  } else {
    console.error("Elementos de ordenação não encontrados");
  }
}

// Restaurar as seleções de filtros e ordenação
document.addEventListener("DOMContentLoaded", function () {
  const userOrder = new URLSearchParams(window.location.search).get(
    "user_order"
  );
  const userDirection = new URLSearchParams(window.location.search).get(
    "user_direction"
  );

  if (userOrder) {
    document.getElementById("orderSelect").value = userOrder;
  }
  if (userDirection) {
    document.getElementById("directionSelect").value = userDirection;
  }

  const fieldOrder = new URLSearchParams(window.location.search).get(
    "field_order"
  );
  const fieldDirection = new URLSearchParams(window.location.search).get(
    "field_direction"
  );

  if (fieldOrder) {
    document.getElementById("orderFieldsSelect").value = fieldOrder;
  }
  if (fieldDirection) {
    document.getElementById("directionFieldsSelect").value = fieldDirection;
  }

  const matchOrder = new URLSearchParams(window.location.search).get(
    "match_order"
  );
  const matchDirection = new URLSearchParams(window.location.search).get(
    "match_direction"
  );

  if (matchOrder) {
    document.getElementById("orderMatchesSelect").value = matchOrder;
  }
  if (matchDirection) {
    document.getElementById("directionMatchesSelect").value = matchDirection;
  }
});

// Mostrar indicador de carregamento durante requisições HTMX
document.addEventListener("htmx:beforeRequest", () => {
  const loadingIndicator = document.getElementById("loading");
  if (loadingIndicator) {
    loadingIndicator.style.display = "block";
  } else {
    console.error("Indicador de carregamento não encontrado: #loading");
  }
});

// Ocultar indicador de carregamento após requisições HTMX
document.addEventListener("htmx:afterSwap", () => {
  const loadingIndicator = document.getElementById("loading");
  if (loadingIndicator) {
    loadingIndicator.style.display = "none";
  } else {
    console.warn("Indicador de carregamento não encontrado para ocultar: #loading");
  }
});
