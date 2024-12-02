function confirmDelete(event) {
  const confirmation = confirm(
    "¿Está seguro de que desea eliminar este depósito?"
  );
  if (!confirmation) {
    event.preventDefault(); // Cancela el envío del formulario si el usuario no confirma
  }
  return confirmation;
}
