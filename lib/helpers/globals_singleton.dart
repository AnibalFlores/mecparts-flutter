class Globals {
  static final Globals _globals = new Globals._internal();
  String url;
  int terminal;
  // TODO Status deberia ser un stream
  int maquinaId = 0;
  String maquinaName = '';
  DateTime iniciolabor;
  DateTime inicioevento;
  int operarioId = 0;
  String operarioName = '';
  bool esmaquina = false;
  bool espap = false;
  bool esaterminar = false;
  int parteId = 0;
  String parteCodigo = '';
  int nroOrden = 0;
  int nroLabor = 0;
  String nota = '';

  factory Globals() {
    return _globals;
  }

  Globals._internal();

  String getMensaje() {
    return (esmaquina ? 'Máquina: ' : 'Operación: ') + maquinaName + '\nOperario: ' + operarioName;
  }
}