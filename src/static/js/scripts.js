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


/* Mapas */
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

// Função para inicializar mapa principal em qualquer página, com verificação do container
function inicializarMapa(idMapa, lat, lng, zoom = 13, markerDraggable = false, onMarkerMoved) {
  lat = parseFloat(String(lat).replace(',', '.'));
  lng = parseFloat(String(lng).replace(',', '.'));

  var map = L.map(idMapa).setView([lat, lng], zoom);

  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      maxZoom: 18,
      minZoom: 12,
      attribution: '© OpenStreetMap'
  }).addTo(map);

  var marker = L.marker([lat, lng], { draggable: markerDraggable }).addTo(map);

  if (markerDraggable && onMarkerMoved) {
      marker.on('dragend', function (e) {
          var pos = e.target.getLatLng();
          onMarkerMoved(pos.lat, pos.lng);
      });

      map.on('click', function (e) {
          marker.setLatLng(e.latlng);
          onMarkerMoved(e.latlng.lat, e.latlng.lng);
      });
  }

  return { map, marker };
}

// Inicializa o mapa principal do campo (exemplo: id "map")
function inicializarMapaPrincipal(lat, lng) {
  inicializarMapa('map', lat, lng, 13, false, null);
}

// Inicializa mapa para edição com interatividade para atualizar inputs lat/lng
function inicializarMapaEdicao(lat, lng, inputLatId, inputLngId) {
  function atualizarInputs(lat, lng) {
      const inputLat = document.getElementById(inputLatId);
      const inputLng = document.getElementById(inputLngId);
      if (inputLat) inputLat.value = lat.toFixed(6);
      if (inputLng) inputLng.value = lng.toFixed(6);
  }

  inicializarMapa('map-edit', lat, lng, 13, true, atualizarInputs);
}

// DOMContentLoaded: configura tudo
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

  // Resetar formulário após swap do resultado login/register
  document.addEventListener("htmx:afterSwap", (event) => {
    if (["login_result", "register_result"].includes(event.target.id)) {
      const form = document.querySelector(`form[hx-target="#${event.target.id}"]`);
      if (form) form.reset();
    }
  });

  // Inicializa mapa edição após modal abrir, com verificação de inputs
  var modalEditar = document.getElementById('modalEditar');
  if (modalEditar) {
      modalEditar.addEventListener('shown.bs.modal', function () {
          const inputLat = document.getElementById('latitude');
          const inputLng = document.getElementById('longitude');

          if (!inputLat || !inputLng) {
            console.log('Inputs latitude/longitude não encontrados ao abrir modal.');
            return;
          }

          const lat = inputLat.value;
          const lng = inputLng.value;
          inicializarMapaEdicao(lat, lng, 'latitude', 'longitude');
      });
  }
});

// Função para inicializar o mapa dentro do modal Editar
let mapEditar; // global
function inicializarMapaEditar(lat, lng) {
  if (mapEditar) {
    mapEditar.remove(); // Limpa mapa anterior
  }

  mapEditar = L.map("mapupdate").setView([lat, lng], 15);

  L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
    maxZoom: 19,
    attribution: "&copy; OpenStreetMap contributors",
  }).addTo(mapEditar);

  const marker = L.marker([lat, lng], { draggable: true }).addTo(mapEditar);

  marker.on("move", function (e) {
    document.getElementById("latitude").value = e.latlng.lat.toFixed(6);
    document.getElementById("longitude").value = e.latlng.lng.toFixed(6);
  });

  mapEditar.on("click", function (e) {
    marker.setLatLng(e.latlng);
    document.getElementById("latitude").value = e.latlng.lat.toFixed(6);
    document.getElementById("longitude").value = e.latlng.lng.toFixed(6);
  });

  setTimeout(() => {
    mapEditar.invalidateSize();
  }, 300);
}


// Evento para inicializar mapa quando modal abrir
document.addEventListener('DOMContentLoaded', function () {
  var modalEditar = document.getElementById('modalEditar');
  if (modalEditar) {
    modalEditar.addEventListener('shown.bs.modal', function () {
      var latInput = document.getElementById('latitude');
      var lngInput = document.getElementById('longitude');

      var lat = latInput ? parseFloat(latInput.value) : 0;
      var lng = lngInput ? parseFloat(lngInput.value) : 0;

      inicializarMapaEditar(lat, lng);
    });
  }
});

// Metodo de pagamento: adicionar/remover campos dinamicamente
document.addEventListener("DOMContentLoaded", function () {
  const checkboxes = document.querySelectorAll(".metodo-checkbox");
  const container = document.getElementById("pagamento-details");

  // Mapeia os valores dos checkboxes aos campos
  const fields = {
    CC: {
      label: "Número do Cartão de Crédito",
      name: "cartao_credito_numero",
      type: "text",
    },
    PayPal: {
      label: "Email do PayPal",
      name: "paypal_email",
      type: "email",
    },
    MBWay: {
      label: "Número de Telemóvel (MB Way)",
      name: "mbway_numero",
      type: "text",
    },
  };

  checkboxes.forEach((cb) => {
    cb.addEventListener("change", () => {
      const value = cb.value;
      const fieldId = `field-${value}`;

      if (cb.checked && !document.getElementById(fieldId)) {
        const field = fields[value];

        if (!field) {
          console.warn(
            `Campo para o método de pagamento "${value}" não foi encontrado.`
          );
          return; // valor não reconhecido
        }

        const div = document.createElement("div");
        div.classList.add("mb-3");
        div.id = fieldId;

        const label = document.createElement("label");
        label.textContent = field.label;
        label.setAttribute("for", field.name);
        label.classList.add("form-label");

        const input = document.createElement("input");
        input.type = field.type;
        input.name = `detalhe_${value}`;
        input.id = field.name;
        input.classList.add("form-control");
        input.required = true;

        div.appendChild(label);
        div.appendChild(input);
        container.appendChild(div);
      }

      // Remover campo
      if (!cb.checked) {
        const existing = document.getElementById(fieldId);
        if (existing) container.removeChild(existing);
      }
    });
  });
});

document.addEventListener('DOMContentLoaded', function () {
    const checkboxes = document.querySelectorAll('.dia-checkbox');

    checkboxes.forEach(checkbox => {
        const sigla = checkbox.getAttribute('data-sigla');
        const detalhesDiv = document.getElementById('detalhes_' + sigla);

        // Mostrar/ocultar campos ao carregar (útil para edições)
        if (checkbox.checked) {
            detalhesDiv.style.display = 'block';
        }

        checkbox.addEventListener('change', function () {
            detalhesDiv.style.display = checkbox.checked ? 'block' : 'none';
        });
    });
});



document.addEventListener("DOMContentLoaded", function () {
  const checkboxes = document.querySelectorAll(".metodo-checkbox");
  const container = document.getElementById("pagamento-details");
  const jsonScript = document.getElementById("detalhes-json");
  let detalhesValores = {};
  if (jsonScript) {
    try {
      detalhesValores = JSON.parse(jsonScript.textContent);
    } catch (e) {
      console.error("Erro ao analisar JSON de detalhes:", e);
    }
  }

  const fields = {
    MBWay: {
      label: "Número de Telemóvel (MB Way)",
      name: "mbway_numero",
      type: "text",
    },
    CC: {
      label: "Número do Cartão de Crédito",
      name: "cartao_credito_numero",
      type: "text",
    },
    PayPal: {
      label: "Email do PayPal",
      name: "paypal_email",
      type: "email",
    },
  };

  const mapeamentoChaves = {
    CartaoCredito: "CC",
    MBWay: "MBWay",
    PayPal: "PayPal",
  };
  

  function toggleField(value, checked) {
    const fieldId = `field-${value}`;
    const chaveReal = mapeamentoChaves[value];

    if (checked && !document.getElementById(fieldId)) {
      const field = fields[value];

      if (!field) {
        console.warn(`Método de pagamento não reconhecido: "${value}"`);
        return;
      }
      if (!chaveReal) {
        console.warn(`Chave real não encontrada para o método: "${value}"`);
        return;
      }

      const div = document.createElement("div");
      div.classList.add("mb-3");
      div.id = fieldId;

      const label = document.createElement("label");
      label.textContent = field.label;
      label.setAttribute("for", field.name);
      label.classList.add("form-label");

      const input = document.createElement("input");
      input.type = field.type;
      input.name = `detalhe_${chaveReal}`;
      input.id = field.name;
      input.classList.add("form-control");
      input.required = true;

      if (detalhesValores && detalhesValores[chaveReal]) {
        input.value = detalhesValores[chaveReal];
      }

      div.appendChild(label);
      div.appendChild(input);
      container.appendChild(div);
    } else if (!checked) {
      const existing = document.getElementById(fieldId);
      if (existing) container.removeChild(existing);
    }
  }
  

  checkboxes.forEach((cb) => {
    toggleField(cb.value, cb.checked); // Cria ao carregar se marcado

    cb.addEventListener("change", () => {
      toggleField(cb.value, cb.checked);
    });
  });
});

