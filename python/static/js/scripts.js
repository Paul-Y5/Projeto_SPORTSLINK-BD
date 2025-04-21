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