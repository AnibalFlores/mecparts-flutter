class Globals {
  static final Globals _globals = new Globals._internal();
  int maquinaId = 0;
  String maquinaName ='';
  int operarioId = 0;
  String operarioName ='';
  bool esmaquina = false;
  int parteId = 0;
  String parteCodigo ='';

  factory Globals() {
    return _globals;
  }

  Globals._internal();

  String getMensaje() {
    return (esmaquina ? 'Máquina: ' : 'Operación: ') + maquinaName + '\nOperario: ' + operarioName;
  }
}