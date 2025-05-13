// Indicadores de carregamento globais e específicos
function showGlobalLoading() {
  const loader = document.getElementById("loading");
  if (loader) loader.style.display = "block";
}

function hideGlobalLoading() {
  const loader = document.getElementById("loading");
  if (loader) loader.style.display = "none";
}

// Indicador específico para formulários de login e registro
function toggleFormLoading(form, show) {
  const formAction = form.getAttribute("hx-post");
  const idMap = {
    "/login": "login_loading",
    "/register": "register_loading",
  };
  const loaderId = idMap[formAction];
  if (!loaderId) return;
  const loader = document.getElementById(loaderId);
  if (loader) loader.style.display = show ? "block" : "none";
}

// Fechar mensagens flash automaticamente
function closeFlashMessages() {
  document.querySelectorAll(".flash-message").forEach((msg) => {
    setTimeout(() => {
      msg.style.display = "none";
    }, 5000);
  });
}

document.addEventListener("DOMContentLoaded", () => {
  closeFlashMessages();

  // HTMX event listeners configurados após DOM pronto
  // Carregamento global
  document.addEventListener("htmx:beforeRequest", showGlobalLoading);
  document.addEventListener("htmx:afterSwap", hideGlobalLoading);

  // Formulários de login/registro
  ["htmx:configRequest", "htmx:afterRequest"].forEach((evtName) => {
    document.addEventListener(evtName, (event) => {
      const form = event.target.closest("form[method]");
      if (form) {
        const isConfig = evtName === "htmx:configRequest";
        toggleFormLoading(form, isConfig);
      }
    });
  });

  document.addEventListener("htmx:afterSwap", (event) => {
    if (["login_result", "register_result"].includes(event.target.id)) {
      const form = document.querySelector(
        `form[hx-target="#${event.target.id}"]`
      );
      if (form) form.reset();
    }
  });
});
