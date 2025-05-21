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
            console.warn('Inputs latitude/longitude não encontrados ao abrir modal.');
            return;
          }

          const lat = inputLat.value;
          const lng = inputLng.value;
          inicializarMapaEdicao(lat, lng, 'latitude', 'longitude');
      });
  }
});

// Função para inicializar o mapa dentro do modal Editar
function inicializarMapaEditar(lat, lng) {
  if (mapEditar) {
    mapEditar.remove(); // remove mapa antigo antes de criar novo
  }

  // Criar o mapa na div #mapEditar
  var mapEditar = L.map('mapEditar').setView([lat, lng], 15);

  // Adicionar tile layer OpenStreetMap
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 19,
    attribution: '&copy; OpenStreetMap contributors'
  }).addTo(mapEditar);

  // Criar marcador e permitir movê-lo
  var marker = L.marker([lat, lng], { draggable: true }).addTo(mapEditar);

  // Atualiza os inputs quando o marcador for movido
  marker.on('move', function (e) {
    var pos = e.latlng;
    document.getElementById('latitude').value = pos.lat.toFixed(6);
    document.getElementById('longitude').value = pos.lng.toFixed(6);
  });

  // Também atualiza o marcador ao clicar no mapa
  mapEditar.on('click', function (e) {
    marker.setLatLng(e.latlng);
    document.getElementById('latitude').value = e.latlng.lat.toFixed(6);
    document.getElementById('longitude').value = e.latlng.lng.toFixed(6);
  });

  return mapEditar;
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

