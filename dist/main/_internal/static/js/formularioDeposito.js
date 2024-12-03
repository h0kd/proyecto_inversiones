// Mostrar u ocultar la sección "Condiciones de Renovación" según el tipo de depósito
function toggleFields() {
  const tipo = document.getElementById("tipo").value;
  const renovacionFieldset = document.getElementById("renovacion_fieldset");

  if (tipo === "Renovable") {
    renovacionFieldset.style.display = "block";
  } else {
    renovacionFieldset.style.display = "none";
  }
}

function updateRenovacionFields() {
  // Obtener valores de los campos principales
  const monto = document.getElementById("monto").value;
  const fechaEmision = document.getElementById("fecha_emision").value;
  const tasaInteres = document.getElementById("tasa_interes").value;

  console.log("Valores actuales:");
  console.log("Monto:", monto);
  console.log("Fecha de Emisión:", fechaEmision);
  console.log("Tasa de Interés:", tasaInteres);

  // Rellenar los campos de renovación
  document.getElementById("capital_renovacion").value = monto;
  document.getElementById("fecha_emision_renovacion").value = fechaEmision;
  document.getElementById("tasa_interes_renovacion").value = tasaInteres;
}

function calculatePlazoRenovacion() {
  const fechaEmision = document.getElementById("fecha_emision").value;
  const fechaVencimiento = document.getElementById("fecha_vencimiento").value;

  if (fechaEmision && fechaVencimiento) {
    const startDate = new Date(fechaEmision);
    const endDate = new Date(fechaVencimiento);

    // Calcular la diferencia en días
    const diferenciaDias = (endDate - startDate) / (1000 * 60 * 60 * 24);

    // Rellenar el campo de plazo
    document.getElementById("plazo_renovacion").value = diferenciaDias;
  } else {
    document.getElementById("plazo_renovacion").value = "";
  }
}
