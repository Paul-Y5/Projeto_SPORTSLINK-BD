document.addEventListener("htmx:configRequest", (event) => {
    let indicatorSelector = event.detail.indicator;

    // Se o indicador não foi definido explicitamente, tenta inferir com base no formulário
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
        console.log("Indicador exibido:", indicatorSelector);
    } else {
        console.error(
            "Indicador não encontrado. Verifique o seletor:",
            indicatorSelector
        );
    }
});

document.addEventListener("htmx:afterRequest", (event) => {
    let indicatorSelector = event.detail.indicator;

    // Se o indicador não foi definido explicitamente, tenta inferir com base no formulário
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
        console.log("Indicador ocultado:", indicatorSelector);
    } else {
        console.warn("Indicador não encontrado para ocultar:", indicatorSelector);
    }
});


document.body.addEventListener("htmx:afterSwap", function (event) {
  
  if (
    event.target.id === "login_result" ||
    event.target.id === "register_result"
  ) {
    
    const form = document.querySelector(`form[hx-target="#${event.target.id}"]`);
    if (form) {
      form.reset();
    }
  }
});