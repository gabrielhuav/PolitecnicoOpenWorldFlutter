/// Resultado normalizado de una solicitud de permiso de ubicación.
///
/// Aislado en su propio archivo para que pueda compartirse entre el servicio,
/// los providers y la UI sin importar geolocator desde la capa de
/// presentación.
enum LocationPermissionStatus {
  /// Permiso concedido (whileInUse o always).
  granted,

  /// Permiso negado por esta sesión. El usuario puede volver a aceptarlo.
  denied,

  /// Permiso negado permanentemente. Hay que enviar al usuario a Ajustes.
  deniedForever,

  /// El servicio de ubicación del sistema operativo está apagado.
  serviceDisabled,
}
