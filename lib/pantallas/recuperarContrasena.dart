import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _emailSent = false;

  Future<void> _resetPassword() async {
    // Validar formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Enviar correo de restablecimiento de contraseña
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      
      setState(() {
        _isLoading = false;
        _emailSent = true;
      });
      
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Se ha enviado un enlace de restablecimiento a tu correo'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      // Manejar errores específicos
      String mensajeError = 'Error al enviar el correo de restablecimiento';
      
      if (e.code == 'user-not-found') {
        mensajeError = 'No existe una cuenta con este correo electrónico';
      } else if (e.code == 'invalid-email') {
        mensajeError = 'El formato del correo electrónico no es válido';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensajeError),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
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
                        'Restablecer Contraseña',
                        style: TextStyle(
                          fontSize: constraints.maxWidth * 0.08,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: constraints.maxHeight * 0.05),
                      
                      // Imagen o icono
                      Icon(
                        Icons.lock_reset,
                        size: 80,
                        color: Colors.lightBlue,
                      ),
                      
                      SizedBox(height: constraints.maxHeight * 0.05),
                      
                      // Instrucciones
                      Text(
                        _emailSent 
                            ? 'Se ha enviado un enlace de restablecimiento a tu correo electrónico. Por favor revisa tu bandeja de entrada y sigue las instrucciones.'
                            : 'Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      
                      SizedBox(height: constraints.maxHeight * 0.05),
                      
                      // Solo mostrar campo de correo si aún no se ha enviado el enlace
                      if (!_emailSent) ...[
                        // Campo de correo electrónico
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Correo electrónico',
                            hintText: 'Ingresa tu correo electrónico',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
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
                        
                        SizedBox(height: constraints.maxHeight * 0.05),
                        
                        // Botón para enviar enlace
                        _isLoading
                            ? CircularProgressIndicator(color: Colors.lightBlue)
                            : ElevatedButton(
                                onPressed: _resetPassword,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.lightBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: buttonHeight * 0.3),
                                  minimumSize: Size(buttonWidth, buttonHeight),
                                ),
                                child: Text(
                                  'Enviar Enlace',
                                  style: TextStyle(
                                    fontSize: buttonWidth * 0.06,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ] else ...[
                        // Botón para volver al inicio de sesión si ya se envió el correo
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: EdgeInsets.symmetric(vertical: buttonHeight * 0.3),
                            minimumSize: Size(buttonWidth, buttonHeight),
                          ),
                          child: Text(
                            'Volver al inicio de sesión',
                            style: TextStyle(
                              fontSize: buttonWidth * 0.06,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      
                      SizedBox(height: constraints.maxHeight * 0.05),
                      
                      // Texto informativo
                      Text(
                        'Si no recibes el correo, revisa tu carpeta de spam o verifica que la dirección sea correcta.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
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
}