# Flang

**Recupera las banderas de los países en el selector de fuentes de entrada de macOS.**

[English](../../README.md) | Español | [Français](README.fr.md) | [Português](README.pt-BR.md) | [中文](README.zh-Hans.md) | [日本語](README.ja.md)

Hasta macOS 12.4, el selector de distribución de teclado en la barra de menús
mostraba la bandera de un país. Apple sustituyó después las banderas por
etiquetas de texto ("ABC", "ES"). Flang es una pequeña app de barra de menús
que devuelve las banderas — y te deja elegir qué bandera, y qué nombre,
representa a cada uno de tus idiomas.

<!-- TODO: captura de pantalla / GIF del selector en la barra de menús -->

## Características

| | |
|---|---|
| Bandera en la barra de menús | La fuente de entrada activa se muestra con su bandera, actualizada al instante |
| Cambio familiar | Haz clic para ver todas tus fuentes de entrada y cambiar, igual que en el menú del sistema |
| Indicador flexible | Bandera y nombre se muestran de forma independiente — uno, ambos o ninguno (recurre al icono del sistema) |
| Dos estilos de bandera | Imágenes de bandera planas (el look clásico) o emojis de bandera nativos |
| Valores por defecto sensatos | Cada distribución de teclado y método de entrada de macOS recibe una bandera por defecto razonable |
| Personalización total | Cualquier bandera, nombre corto y nombre completo personalizados para cada idioma |
| Huella mínima | Sin recolección de datos, se inicia con el login, unos pocos megabytes; la única llamada de red es una comprobación diaria opcional de actualizaciones |

Los idiomas no están ligados a países — precisamente por eso Flang convierte
la bandera en una elección personal. ¿Prefieres la bandera canadiense para el
francés, o la mexicana para el español? Dos clics.

## Instalación

Descarga el último DMG desde
[GitHub Releases](https://github.com/e1ernal/Flang/releases), ábrelo y
arrastra Flang.app a Aplicaciones — luego lee lo siguiente antes de abrirlo.

Para compilar desde el código fuente en su lugar:

```bash
git clone https://github.com/e1ernal/Flang.git
open Flang/Flang.xcodeproj
```

Compila y ejecuta con Cmd+R (Xcode 16 o posterior, macOS 13 Ventura o posterior).

### Abrir una app sin firmar

Flang no está notarizada por Apple. La notarización requiere una membresía de
pago en el Apple Developer Program, que este proyecto todavía no tiene —
está previsto para después de que la 1.0 demuestre que hay una audiencia por
la que merezca la pena pagar (ver la [hoja de ruta](#hoja-de-ruta)). Hasta
entonces, Gatekeeper de macOS bloquea un doble clic normal con "Flang no se
puede abrir porque Apple no puede comprobar que no contiene malware".

Esto es lo esperado, no un error ni una señal de que algo va mal. Para
abrirla la primera vez:

1. Haz clic derecho (o Control-clic) en Flang.app en Aplicaciones y elige **Abrir**.
2. Haz clic en **Abrir** de nuevo en el diálogo que aparece.

<!-- TODO(docs/images/gatekeeper-open.png): captura del menú contextual "Abrir"
sobre Flang.app, o del diálogo de Gatekeeper resultante -->

Solo necesitas hacer esto una vez — cada inicio posterior, incluidas las
futuras actualizaciones, se abre con normalidad.

## Uso

1. Inicia Flang — aparecerá una bandera en tu barra de menús.
2. Haz clic para cambiar de fuente de entrada; clic derecho para Ajustes y Salir.
3. Opcional: oculta el selector del sistema en
   Ajustes del Sistema — Teclado — desmarca "Mostrar el menú de entrada en la
   barra de menús". macOS no permite que las apps hagan esto automáticamente,
   así que es un paso manual único.

   <img src="../images/hide-system-switcher.png" width="500" alt="Ajustes del Sistema — Teclado, con &quot;Mostrar el menú de entrada en la barra de menús&quot; resaltado">

4. Para añadir o quitar una distribución de teclado, abre Ajustes — Fuentes de
   entrada y usa el botón "+" (o Eliminar en una fuente) — ambos abren
   Ajustes del Sistema — Teclado — Fuentes de entrada, donde macOS lo gestiona
   directamente.

   <img src="../images/add-input-source.png" width="500" alt="La pestaña Fuentes de entrada de Flang, con el botón &quot;+&quot; resaltado">

## Preguntas frecuentes

**¿Flang sustituye al selector del sistema?**
Funcionalmente sí: lista y cambia las mismas fuentes de entrada usando las
mismas API del sistema. El indicador propio del sistema solo se puede ocultar
manualmente (ver Uso).

**¿Flang necesita internet?**
No. La única llamada de red opcional es una comprobación diaria de nuevas
versiones en GitHub. Nada sobre ti o tu sistema se envía jamás a ningún sitio.

## Hoja de ruta

- [x] Indicador en la barra de menús con la bandera de la fuente de entrada activa
- [x] Cambiar de fuente de entrada desde el menú desplegable
- [x] Mapa de banderas por defecto para todas las distribuciones y métodos de entrada de macOS
- [x] Modos de bandera en imagen y emoji
- [x] Ajustes independientes de bandera y nombre, con vista previa en vivo
- [x] Ventana de ajustes: bandera, nombre corto y nombre completo personalizados por idioma
- [x] Inicio con el login, consejos en el primer arranque
- [x] Comprobación de actualizaciones contra GitHub Releases
- [x] Interfaz localizada en EN y RU
- [x] Compilaciones DMG distribuibles vía GitHub Releases
- [x] README localizado (ES, FR, JA, PT-BR, ZH-Hans)
- [ ] Compilaciones firmadas y actualizaciones automáticas

## Contribuir

Los issues y pull requests son bienvenidos.

## Créditos y licencia

| | |
|---|---|
| Imágenes de banderas | [flag-icons](https://github.com/lipis/flag-icons) por lipis, Licencia MIT |
| Flang | Publicado bajo la [Licencia MIT](../../LICENSE) |
