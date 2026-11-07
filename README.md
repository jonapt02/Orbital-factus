# Orbital Factus

Aplicación de cotizaciones y facturación para Orbital Engineering Solutions SAS.

Hecha en Flutter, funciona en la web, en Linux, en Windows y en el teléfono. Los datos se guardan en el mismo dispositivo, no en internet, así que no depende de servidores ni de suscripciones.

## Qué hace

Permite crear cotizaciones para clientes, agregar productos o servicios con su cantidad y valor, calcular el total automáticamente y exportar todo a un PDF con el logo de la empresa listo para enviar al cliente.

También tiene un panel principal con las estadísticas del negocio (cuánto se ha cotizado, cuántas cotizaciones hay, qué proveedor aparece más) y pantallas separadas para ver los clientes y los proveedores que ya están registrados en las cotizaciones.

## Cómo está organizado

La idea del proyecto es simple: separar lo visual de lo funcional. Todo lo relacionado con colores, tipografía, botones y estilos vive en una carpeta de tema. Todo lo que son datos vive en modelos y un repositorio. Las pantallas solo se encargan de mostrar la información.

El diseño es monocromático, blanco y negro con grises, tipografía Space Grotesk para títulos e Inter para el resto. Sin colores decorativos, sin sombras, sin emojis. La intención es que se vea como una herramienta de ingeniería, no como una app de contabilidad tradicional.

## Cómo correrla

Primero instala Flutter en tu equipo (versión 3.2 o superior).

Luego, desde la carpeta del proyecto:
flutter pub get

text

Si es la primera vez que la abres, o si cambiaste algún modelo de datos, necesitas generar unos archivos internos que Flutter usa para guardar la información:
dart run build_runner build --delete-conflicting-outputs

text

Y después, para verla funcionando:
flutter run -d chrome

text

Cambia `chrome` por `linux`, `windows` o el identificador del teléfono según dónde quieras probarla.

## Cómo se usa

Al abrir la app verás el panel principal con las estadísticas y las últimas cotizaciones. En el menú de la izquierda (o en el botón de menú si estás en el teléfono) están los cuatro módulos:

El dashboard muestra el resumen del negocio.

Cotizaciones es la lista completa, con un buscador para encontrar por cliente o por número.

Clientes muestra todos los clientes que han tenido al menos una cotización, con el total cotizado a cada uno.

Proveedores muestra lo mismo pero agrupado por proveedor.

Para crear una cotización nueva, hay un botón en la parte superior del menú lateral. Al hacer clic se abre un formulario donde pones el título del proyecto, los datos del cliente, una descripción si quieres, y luego vas agregando ítems uno por uno. Cada ítem tiene nombre del producto, cantidad, valor unitario, un proveedor opcional y un enlace opcional.

El total se actualiza solo a medida que agregas ítems.

Cuando guardas, la cotización aparece en el dashboard y en la lista completa. Desde ahí puedes editarla, exportarla a PDF o eliminarla.

## El PDF

El PDF que se genera incluye el logo de la empresa, el número y la fecha, el título del proyecto, la descripción, los datos del cliente, la tabla de ítems con sus valores y el total. Todo en blanco y negro, listo para enviar.

En la web se abre en una pestaña nueva del navegador. En el teléfono abre la opción de compartir o guardar. En el escritorio abre el diálogo de impresión.

Si quieres cambiar el correo o los datos de la empresa que aparecen al pie del PDF, se editan en el archivo `lib/services/pdf_service.dart`.

## El logo y los iconos

El logo está en `assets/images/logo_completo.png`. La versión pequeña, sin el texto, está en `assets/images/logo_isotipo.png` y se usa en el menú lateral.

El icono de la app (el que aparece en el escritorio, en la pestaña del navegador y en el teléfono) se genera con el paquete `flutter_launcher_icons` a partir de `assets/images/app_icon.png`. Si quieres cambiarlo, reemplaza esa imagen y ejecuta:
dart run flutter_launcher_icons

text

## Qué falta

El proyecto está funcional pero todavía se pueden agregar cosas útiles:

La numeración automática consecutiva de las cotizaciones (ahora mismo el número se genera con la fecha y el instante, pero no es estrictamente secuencial).

Los estados de cada cotización (borrador, enviada, aprobada, rechazada) con un indicador visual en la tabla.

Una pantalla de detalle para ver una cotización completa sin tener que abrir el formulario de edición.

Una pantalla de configuración donde se guarden los datos de la empresa (NIT, dirección, teléfono) para que no estén escritos directamente en el código del PDF.

Exportar la lista de cotizaciones a CSV o Excel.

## Contacto

Orbital Engineering Solutions SAS

orbitalsolutions2@gmail.com
