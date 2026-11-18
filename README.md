# MVI Lab

Una app pequeña de Flutter para ver **Model–View–Intent** en funcionamiento, basada en el contador de la presentación y el guion adjuntos. Interfaz en español, adaptable a móvil y escritorio, con incrementar, decrementar, reiniciar y un historial de las últimas ocho transiciones.

## Video de la exposición:
https://youtu.be/W_eoO2dOqYU

## Ejecutar

Necesitas Flutter con Dart 3.11 o superior y un dispositivo compatible. No requiere cuentas, claves, backend ni paquetes externos en ejecución.

```sh
flutter pub get
flutter run -d chrome
```

Si aparece **Failed to launch browser after 3 tries**, inicia el servidor y abre el navegador manualmente:

```sh
flutter run -d web-server --web-hostname=127.0.0.1 --web-port=8080
```

Espera a que Flutter indique que la app está disponible y abre **http://127.0.0.1:8080** en Chrome o Edge. Mantén la terminal abierta mientras utilizas la app; para detenerla, pulsa `Ctrl+C`. Este modo evita el lanzamiento automático del navegador y ofrece soporte de depuración limitado.

### Ejecutar con el botón de VS Code

El proyecto incluye `.vscode/launch.json` con la configuración **MVI Lab (navegador manual)**:

1. Si VS Code ya estaba abierto, usa `Ctrl+Shift+P` → **Developer: Reload Window** para que reconozca el dispositivo Web Server.
2. Abre **Ejecutar y depurar** (`Ctrl+Shift+D`) y selecciona **MVI Lab (navegador manual)**.
3. Pulsa el triángulo o `F5`. Espera a que aparezca la dirección y abre **http://127.0.0.1:8080** en tu navegador.
4. Para detener el servidor, usa el botón cuadrado de detener de VS Code (`Shift+F5`).

Esta configuración también se aplica a las acciones Run/Debug de los archivos de `lib`. Ejecuta la app sin adjuntar el depurador; los puntos de interrupción no se activarán. Si ya tienes un servidor de la app en el puerto 8080, detén esa ejecución antes de iniciar otra.

Para Android, inicia un emulador o conecta un teléfono con depuración USB y ejecuta `flutter run`. Puedes consultar los dispositivos con `flutter devices`. El proyecto incluye las plataformas Android y web.

Si Flutter no se reconoce en PowerShell y tu SDK está en la ubicación de esta máquina:

```powershell
& 'C:\Development\flutter\bin\flutter.bat' run -d chrome
```

## Dónde se ve MVI

```text
Usuario → CounterPage → CounterIntent → CounterStore → caso de uso
                ↑                            ↓             ↓
                └──── CounterState nuevo ← resultado ← repositorio
```

- **View:** `CounterPage` observa el store mediante `ListenableBuilder`. Los botones solo envían intenciones.
- **Intent:** las clases selladas `LoadCounter`, `IncrementCounter`, `DecrementCounter`, `ResetCounter` y `RetryCounter` expresan acciones, sin cálculos.
- **Model:** `CounterState` es una instantánea inmutable del valor, carga, error, revisión e historial. Se publica una instancia nueva en cada transición.
- **Procesamiento:** `CounterStore` coordina los casos de uso y es la única fuente de estado. Las operaciones asíncronas se procesan en orden para evitar incrementos perdidos.

No hace falta una biblioteca MVI para expresar este contrato. `ChangeNotifier` notifica cambios; la disciplina de intenciones y estados es la que establece MVI.

## Arquitectura limpia

MVI organiza la **presentación**; la arquitectura limpia organiza las **dependencias de toda la app**. Se complementan.

```text
lib/
├── main.dart
├── app/
│   ├── app.dart                 # Inicio y ciclo de vida del store
│   ├── dependencies.dart        # Composición e inyección por constructor
│   └── theme.dart
└── features/counter/
    ├── domain/
    │   ├── entities/            # Counter y sus límites
    │   ├── repositories/       # Contrato CounterRepository
    │   └── use_cases/          # GetCounter y UpdateCounter
    ├── data/repositories/      # Implementación en memoria
    └── presentation/
        ├── mvi/                # Intent, State y Store
        ├── pages/
        └── widgets/
```

Dependencias de código: **Presentación → Dominio ← Datos**. El dominio es Dart puro y no importa Flutter, widgets ni implementaciones de datos. La raíz de composición conecta el repositorio con los casos de uso y el store. Cambiar a SQLite o a una API requiere implementar `CounterRepository` y cambiar esa composición; la vista y las reglas permanecen independientes del mecanismo de almacenamiento.

La entidad de negocio `Counter` y el modelo de pantalla `CounterState` tienen responsabilidades distintas: el primero valida el valor; el segundo contiene lo que la vista necesita mostrar.

## Comportamiento y alcance

- El rango **0–99** es una regla elegida para esta demostración. Se valida en el dominio; la vista deshabilita las acciones que excederían los límites.
- El repositorio conserva datos **solo en memoria durante la sesión**. Cerrar o recargar la app crea un contador en cero.
- La latencia artificial de **250 ms** permite observar el procesamiento; no representa una llamada de red.
- Se distinguen estados inicial, carga, actualización, listo y error. Mientras se guarda, se conserva el último valor confirmado.
- Si falla el almacenamiento, no se publica un valor sin guardar y se permite reintentar la intención fallida. Las intenciones posteriores quedan descartadas hasta resolver el error.
- El repositorio de demostración no provoca errores artificialmente desde la UI; las pruebas inyectan fallos de lectura y escritura.
- El historial guarda las últimas ocho operaciones confirmadas; el total de revisiones continúa creciendo. Reiniciar crea una transición a cero y conserva el historial.
- El store libera sus listeners al salir y no publica resultados después de `dispose`.

## Verificación

```sh
flutter analyze
flutter test
flutter build web
```

Las pruebas cubren reglas de dominio, almacenamiento de sesión, secuencia de estados, concurrencia, fallos y reintentos, inmutabilidad, límite del historial, liberación del store e interacción de widgets. También verifican la disposición a 320 y 1280 píxeles, incluido texto ampliado.

## Recorrido para exponerlo

1. Pulsa **Incrementar**: observa `IncrementCounter()` y el cambio `0 → 1`.
2. Explica que el botón solicita la acción; `UpdateCounter` calcula y valida, y el repositorio guarda.
3. Señala que el nuevo `CounterState` actualiza la vista automáticamente.
4. Prueba decrementar y reiniciar, y muestra el historial.
5. Abre **Cómo está organizada la app** y relaciona cada capa con las carpetas del proyecto.

El ejemplo Kotlin/Compose de los documentos se adaptó a Flutter conservando la separación entre intención, procesamiento y estado.
