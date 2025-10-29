# Plataforma de Gestión - Gemini Ambiental (Entorno de Pruebas QA)

Este repositorio es una copia del proyecto original de **Gemini Ambiental S.A.S.**, configurado exclusivamente como un **Entorno de Pruebas (QA)**.

Su propósito es la ejecución del Plan de Pruebas `PMP-GA-2025` (basado en ISO/IEC 29119) contra una base de datos de prueba dedicada (`gemini_ambiental_TEST`) para validar la funcionalidad, seguridad e integridad del sistema antes de cualquier despliegue.

## Advertencia: Entorno de Pruebas

Este repositorio **no es para desarrollo de nuevas funcionalidades**. Su `pom.xml` contiene dependencias de prueba adicionales (H2, RestAssured, Spring Security Test) y su configuración apunta a una base de datos de QA.

-----

## Puesta en Marcha (Entorno de QA)

Siga estos pasos para configurar y ejecutar el entorno de pruebas en su máquina local.

### 1\. Prerrequisitos

  * **JDK 17** (Java Development Kit)
  * **Apache Maven 3.9** o superior
  * Un servidor de base de datos **MySQL 8**

### 2\. Clonar el Repositorio

```bash
git clone https://github.com/julianReyes-dev/BackendGeminiAmbiental-EntornoDePruebas.git
cd BackendGeminiAmbiental-EntornoDePruebas
```

### 3\. Configuración de la Base de Datos de Pruebas

Este es el paso más importante. Este entorno utiliza una base de datos aislada.

1.  Abra su cliente de MySQL (MySQL Workbench, DBeaver, etc.).
2.  Ejecute el script SQL completo que se encuentra en la raíz del proyecto:
    ```sql
    gemini_ambiental_TEST.sql
    ```
3.  Este script creará la nueva base de datos `gemini_ambiental_TEST`, el usuario de pruebas `gemini_test` (con contraseña `T3st_G3m1n1@2025`) y cargará todas las tablas, triggers, vistas y datos de prueba.

### 4\. Configuración del Backend

Asegúrese de que su archivo `application.properties` (o un `application-test.properties` si usas perfiles) apunte a la nueva base de datos de PRUEBAS.

**Ubicación:** `src/main/resources/application.properties`

```properties
# ===============================================
# CONFIGURACIÓN DEL ENTORNO DE PRUEBAS (QA)
# ===============================================

# Configuración de la Base de Datos de Pruebas
spring.datasource.url=jdbc:mysql://localhost:3306/gemini_ambiental_TEST?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
spring.datasource.username=gemini_test
spring.datasource.password=T3st_G3m1n1@2025

# Configuración de JPA (Hibernate)
spring.jpa.hibernate.ddl-auto=validate
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true

# Server Configuration
server.port=8080

# Configuración de CORS segura para QA
# Reemplazar por la URL del frontend de QA (ej. http://qa.geminiambiental.com)
spring.web.cors.allowed-origins=http://localhost:3000
spring.web.cors.allowed-methods=GET,POST,PUT,DELETE,OPTIONS
spring.web.cors.allowed-headers=*
```

> **NOTA IMPORTANTE (ISO 29119):**
> De acuerdo al plan de pruebas, es **mandatorio** usar `spring.jpa.hibernate.ddl-auto=validate` o `none` en el entorno de QA. Esto previene que Hibernate modifique o borre el esquema de la base de datos de pruebas durante la ejecución.

### 5\. Ejecutar la Aplicación

```bash
mvn spring-boot:run
```

El servidor estará disponible en `http://localhost:8080`.

-----

## 🧪 Ejecución del Plan de Pruebas

Este repositorio está diseñado para ejecutar todos los niveles de prueba definidos en el plan `PMP-GA-2025`.

### 1\. Pruebas Unitarias (T1)

Estas pruebas (basadas en Mockito) validan la lógica de negocio aislada. Se encuentran en `src/test/java`.

```bash
# Ejecuta solo las pruebas unitarias (Mockito)
mvn test
```

Los informes de resultados se generan en `target/surefire-reports/`.
