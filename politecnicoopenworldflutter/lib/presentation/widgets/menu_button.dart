import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback?
      onPressed; // Lo hacemos nullable para poder desactivar el botón
  final bool isSecondary;
  final bool isLoading; // NUEVA PROPIEDAD

  const MenuButton({
    Key? key,
    required this.title,
    required this.icon,
    required this.onPressed,
    this.isSecondary = false,
    this.isLoading = false, // Por defecto es falso
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        // Si está cargando, desactivamos el botón mandando null al onPressed
        onPressed: isLoading ? null : onPressed,
        // Si está cargando, no mostramos ícono
        icon: isLoading
            ? const SizedBox.shrink()
            : Icon(icon, color: isSecondary ? Colors.white : Colors.black87),
        // Si está cargando, mostramos el spinner; si no, el texto normal
        label: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: isSecondary ? Colors.white : Colors.black87,
                  strokeWidth: 3,
                ),
              )
            : Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSecondary ? Colors.white : Colors.black87,
                ),
              ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary ? Colors.transparent : Colors.white,
          foregroundColor: isSecondary ? Colors.white : Colors.black87,
          elevation: isSecondary ? 0 : 5,
          side: isSecondary
              ? const BorderSide(color: Colors.white54, width: 2)
              : BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          // Mantiene el color cuando está deshabilitado por el "isLoading"
          disabledBackgroundColor:
              isSecondary ? Colors.transparent : Colors.white70,
        ),
      ),
    );
  }
}
