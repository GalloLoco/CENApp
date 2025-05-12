import 'package:cenapp/pantallas/inicio.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controladores para los campos de texto
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoPaternoController = TextEditingController();
  final TextEditingController _apellidoMaternoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController(); // Cambiado a email
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmarPasswordController = TextEditingController();
  
  // Valor por defecto del grado
  String _gradoSeleccionado = 'Ingeniero';
  
  // Lista de opciones para el campo grado
  final List<String> _grados = ['Ingeniero', 'Arquitecto', 'Estudiante', 'Otro'];
  
  // Variable para controlar la carga
  bool _isLoading = false;
  
  // Clave global para acceder al formulario
  final _formKey = GlobalKey<FormState>();

  // Función para validar y registrar al usuario
  Future<void> _registrarUsuario() async {
    // Validar formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Verificar que las contraseñas coincidan
    if (_passwordController.text != _confirmarPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }
    
    // Mostrar diálogo de confirmación
    bool confirmar = await _mostrarDialogoConfirmacion();
    if (!confirmar) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Crear usuario en Firebase Authentication con correo real
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      // Guardar datos adicionales en Firestore
      await FirebaseFirestore.instance.collection('usuarios').doc(userCredential.user!.uid).set({
        'nombre': _nombreController.text,
        'apellidoPaterno': _apellidoPaternoController.text,
        'apellidoMaterno': _apellidoMaternoController.text,
        'grado': _gradoSeleccionado,
        'email': _emailController.text.trim(),
        'fechaRegistro': FieldValue.serverTimestamp(),
      });
      
      setState(() {
        _isLoading = false;
      });
      
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario registrado con éxito'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Regresar a la pantalla de inicio después de un breve retraso
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false, // Elimina todas las rutas anteriores
        );
      });
      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      // Manejar errores específicos de Firebase Authentication
      String mensajeError = 'Error al registrar usuario';
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          mensajeError = 'Este correo electrónico ya está registrado';
        } else if (e.code == 'weak-password') {
          mensajeError = 'La contraseña es demasiado débil';
        } else if (e.code == 'invalid-email') {
          mensajeError = 'El formato del correo electrónico no es válido';
        }
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensajeError),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // Diálogo de confirmación
  Future<bool> _mostrarDialogoConfirmacion() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar registro'),
        content: const Text('¿Estás seguro de que los datos son correctos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  void dispose() {
    // Liberar recursos
    _nombreController.dispose();
    _apellidoPaternoController.dispose();
    _apellidoMaternoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmarPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Image.asset('assets/logoCenapp.png', height: 50),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double fieldWidth = constraints.maxWidth * 0.8;
          double buttonWidth = constraints.maxWidth * 0.7;
          double buttonHeight = constraints.maxHeight * 0.08;

          return SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: constraints.maxHeight * 0.05),
                      Text(
                        'Registrarse',
                        style: TextStyle(
                          fontSize: constraints.maxWidth * 0.1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: constraints.maxHeight * 0.05),
                      
                      // Nombre
                      _buildInputField(
                        Icons.person, 
                        'Nombre', 
                        _nombreController, 
                        fieldWidth,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu nombre';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: constraints.maxHeight * 0.02),
                      
                      // Apellido Paterno
                      _buildInputField(
                        Icons.person, 
                        'Apellido Paterno', 
                        _apellidoPaternoController, 
                        fieldWidth,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu apellido paterno';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: constraints.maxHeight * 0.02),
                      
                      // Apellido Materno
                      _buildInputField(
                        Icons.person, 
                        'Apellido Materno', 
                        _apellidoMaternoController, 
                        fieldWidth,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu apellido materno';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: constraints.maxHeight * 0.02),
                      
                      // Grado (Dropdown)
                      SizedBox(
                        width: fieldWidth,
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.engineering),
                            border: OutlineInputBorder(),
                            labelText: 'Grado',
                          ),
                          value: _gradoSeleccionado,
                          items: _grados.map((String grado) {
                            return DropdownMenuItem<String>(
                              value: grado,
                              child: Text(grado),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _gradoSeleccionado = newValue!;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor selecciona un grado';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: constraints.maxHeight * 0.02),
                      
                      // Correo electrónico (cambiado de nombre de usuario)
                      _buildInputField(
                        Icons.email, 
                        'Correo electrónico', 
                        _emailController, 
                        fieldWidth,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu correo electrónico';
                          }
                          // Validar formato de email
                          bool emailValid = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value);
                          if (!emailValid) {
                            return 'Ingresa un correo electrónico válido';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: constraints.maxHeight * 0.02),
                      
                      // Contraseña
                      _buildInputField(
                        Icons.lock, 
                        'Contraseña', 
                        _passwordController, 
                        fieldWidth,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa una contraseña';
                          }
                          if (value.length < 6) {
                            return 'La contraseña debe tener al menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: constraints.maxHeight * 0.02),
                      
                      // Repetir contraseña
                      _buildInputField(
                        Icons.lock, 
                        'Repetir contraseña', 
                        _confirmarPasswordController, 
                        fieldWidth,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor repite la contraseña';
                          }
                          if (value != _passwordController.text) {
                            return 'Las contraseñas no coinciden';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: constraints.maxHeight * 0.05),
                      
                      // Botón de registro
                      _isLoading
                          ? CircularProgressIndicator()
                          : _buildButton(
                              context,
                              'Aceptar',
                              buttonWidth,
                              buttonHeight,
                              _registrarUsuario,
                            ),
                      SizedBox(height: constraints.maxHeight * 0.1),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputField(
    IconData icon,
    String hintText,
    TextEditingController controller,
    double width, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      width: width,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hintText,
          border: OutlineInputBorder(),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    String text,
    double width,
    double height,
    Function() onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: EdgeInsets.symmetric(vertical: height * 0.3),
        minimumSize: Size(width, height),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: width * 0.08,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}