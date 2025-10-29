# 🛠️ Guía de Desarrollo – HOMELAB-project

> Documentación específica para el mantenimiento y ampliación de **HOMELAB-project**. Sigue estas instrucciones para entender, desplegar y extender el proyecto. Todo el stack vive detrás de **Nginx**.

---

## 📑 Índice
1. [Requisitos](#requisitos)
2. [Objetivo del Proyecto](#objetivo-del-proyecto)
3. [Tareas del Proyecto](#tareas-del-proyecto)
4. [Bases de Instalación](#bases-de-instalacion)
5. [Comandos Esenciales](#comandos-esenciales)
6. [Permisos del Sistema](#permisos-del-sistema)
7. [Servidor Nginx](#servidor-nginx)
8. [Variables de Entorno](#variables-de-entorno)
9. [Apartados en Laravel y Vue](#apartados-en-laravel-y-vue)
10. [Roles y Permisos (Spatie)](#roles-y-permisos-spatie)
11. [CRUD de Usuarios](#crud-de-usuarios)
12. [Estructura del Proyecto](#estructura-del-proyecto)
13. [Recursos Útiles](#recursos-utiles)

---

<a id="requisitos"></a>
## 🖥️ Requisitos

### 🧑‍💻 Para desarrolladores

| Herramienta | Versión mínima |
|-------------|---------------|
| Git | v2.42 |
| VSCode | v1.100 |
| NodeJS | v20 |
| npm | v11 |
| PHP | v8.4 |

### 🎲 Para el servidor

| Herramienta | Versión mínima |
|-------------|---------------|
| Ubuntu Server | 22.04 |
| Nginx | 1.18 |
| MySQL | 10 |
| phpMyAdmin | 5.2 |
| Certbot | 2.42 |
| SSH | 10 |

### 👤 Para usuarios finales

```
CPU: Intel Core i3-7300 / AMD Ryzen 3 1300X o superior
RAM: 4 GB+
Disco: 32 GB+
OS: Windows 10 x64 / Ubuntu 22.04 x64 o superior
Navegador: Chrome 137 / Firefox 137 o superior
```

---

<a id="objetivo-del-proyecto"></a>
## 🎯 Objetivo del Proyecto

> Proveer una plataforma integral para el desarrollo de una plataforma VR. Este proyecto piloto respalda la tesis técnica, fomenta el uso ético de las TIC y sirve de guía educativa.

---

<a id="tareas-del-proyecto"></a>
## 🗂️ Tareas del Proyecto

- [ ] Configurar base de datos MySQL
- [ ] Desplegar servidor Linux + Nginx + dominio
- [ ] Implementar backend PHP
- [ ] Implementar frontend HTML + CSS + JS
- [ ] Autenticación de usuarios
- [ ] Roles y permisos

---

<a id="bases-de-instalacion"></a>
## 🧊 Bases de Instalación

```bash
# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Paquetes base
sudo apt install -y git curl wget zip unzip tar nano tree ufw \
  nginx mariadb-server php8.4 php8.4-{mysql,curl,gd,mbstring,xml,zip} \
  certbot python3-certbot-nginx composer nodejs npm

# Instalar PHP 8.4 script alternativo (opcional)
/bin/bash -c "$(curl -fsSL https://php.new/install/linux/8.4)"
```

Configurar **phpMyAdmin** (opcional):
```bash
cd /usr/share
wget https://files.phpmyadmin.net/phpMyAdmin/5.2.2/phpMyAdmin-5.2.2-all-languages.zip
unzip phpMyAdmin-5.2.2-all-languages.zip
mv phpMyAdmin-5.2.2-all-languages phpmyadmin
```

Configurar **Certbot**:
```bash
sudo certbot --nginx -d <tu_dominio>
```
---

<a id="permisos-del-sistema"></a>
## 🚩 Permisos del Sistema

```bash
# Establecer propietario
sudo chown -R <user>:www-data /var/www/llg
# Directorios 775 / Archivos 664
sudo find /var/www/llg -type d -exec chmod 775 {} \;
sudo find /var/www/llg -type f -exec chmod 664 {} \;
# ACL para herencia permanente
sudo setfacl -R -d -m u:<user>:rwx,g:www-data:rwx,o:rx /var/www/llg
# Directorios críticos de Laravel
sudo chmod -R ug+rwx /var/www/llg/storage /var/www/llg/bootstrap/cache
```

---

<a id="servidor-nginx"></a>
## 💻 Servidor Nginx

Ejemplo de *server block* con placeholders (rellena los valores entre <>):

```nginx.conf
server {
    listen 3000;  # ← Cambiado de 80 a 3000
    listen [::]:3000;  # ← IPv6
    root /var/www/html;
    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }

    location ~ /\.ht {
        deny all;
    }

    error_page 404 /404.html;
    location = /404.html {
        internal;
    }

    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        internal;
    }
}
```

> Recarga Nginx después de modificar:
> ```bash
> sudo nginx -t && sudo systemctl reload nginx
> ```

---

<a id="dockerfile"></a>
## 💻 Dockerfile

```Dockerfile
FROM php:8.3-fpm

# Instalar todas las dependencias del sistema y extensiones PHP en un solo RUN
RUN apt-get update && apt-get install -y \
    nginx \
    supervisor \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libmariadb-dev-compat \
    libmariadb-dev \
    zip \
    unzip \
    curl \
    && docker-php-ext-install \
    pdo \
    pdo_mysql \
    mysqli \
    gd \
    opcache \
    zip \
    mbstring \
    exif \
    pcntl \
    bcmath \
    sockets \
    && rm -rf /var/lib/apt/lists/*

# Copiar código fuente y configurar permisos
COPY . /var/www/html
WORKDIR /var/www/html
RUN chown -R www-data:www-data /var/www/html \
    && chown -R www-data:www-data /var/www/html/storage

# Configurar Nginx
COPY ./nginx.conf /etc/nginx/sites-available/default
RUN ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default \
    && rm -f /etc/nginx/sites-enabled/default.conf

# Configurar PHP-FPM y Supervisord
COPY ./php-fpm.conf /usr/local/etc/php-fpm.d/www.conf
COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Exponer puerto y comando de inicio
EXPOSE 80
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
```

---

<a id="variables-de-entorno"></a>
## 🎯 Variables de Entorno

```.env
DB_CONNECTION=
DB_HOST=
DB_DATABASE=
DB_PORT=
DB_USERNAME=
DB_PASSWORD=
DB_CHARSET=
```

---

<a id="nixpacks"></a>
## ⚓ Nixpacks

```nixpacks.toml
[phases.setup]
nixPkgs = [
    "php83",
    "php83Extensions.redis",
    "php83Extensions.mbstring",
    "php83Extensions.curl",
    "php83Extensions.pdo",
    "php83Extensions.pdo_mysql",
    "php83Extensions.bcmath",
    "php83Extensions.tokenizer",
    "php83Extensions.dom",
    "php83Extensions.gd",
    "php83Extensions.fileinfo",
    "php83Extensions.xml",
    "php83Extensions.zip",
    "phpPackages.composer",
    "nodejs_20",
    "python311Packages.supervisor",
    "nginx",
    "libmysqlclient",
    "curl",
    "wget"
]

[phases.build]
cmds = [
  "mkdir -p /var/www/html",
  "cp -r . /var/www/html"
]

[start]
cmd = '/usr/bin/supervisord -c /var/www/html/supervisord.conf'
```

---

<a id="supervisord"></a>
## 📇 supervisord

```supervisord.conf
[supervisord]
nodaemon=true
user=root

[program:php-fpm]
command=/usr/local/sbin/php-fpm -F
stdout_logfile=/dev/stdout
stderr_logfile=/dev/stderr
autostart=true
autorestart=true
redirect_stderr=true

[program:nginx]
command=nginx -g "daemon off;"
stdout_logfile=/dev/stdout
stderr_logfile=/dev/stderr
autostart=true
autorestart=true
redirect_stderr=true
```

---

<a id="php-fpm"></a>
## 📇 php-fpm

```php-fpm.conf
[www]
user = www-data
group = www-data
listen = 127.0.0.1:9000
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
```

---

<a id="estructura-del-proyecto"></a>
## 🏗️ Estructura del Proyecto

```text
/roepard-login
│
├── /api                            # Backend del proyecto con endpoints REST
│   ├── /config                     # Archivos de configuración
│   │   ├── db.php                  # Configuración de la base de datos
│   │   └── env.php                 # Variables de entorno del proyecto
│   ├── /controllers                # Controladores para la lógica de negocio
│   │   ├── AuthController.php      # Controlador de autenticación
│   │   ├── ListUserController.php  # Controlador para listar usuarios
│   │   ├── LogoutController.php    # Controlador para cerrar sesión
│   │   └── RegisterController.php  # Controlador para registro de usuarios
│   ├── /core                       # Núcleo del sistema
│   │   └── DBConfig.php            # Configuración y conexión a la base de datos
│   ├── /middleware                 # Middleware para filtrar solicitudes
│   │   └── auth.php                # Middleware de autenticación
│   ├── /models                     # Modelos de datos
│   │   ├── UserAuth.php            # Modelo para autenticación de usuarios
│   │   ├── UserList.php            # Modelo para listar usuarios
│   │   └── UserRegister.php        # Modelo para registro de usuarios
│   ├── /services                   # Servicios para operaciones complejas
│   │   ├── AuthService.php         # Servicio de autenticación
│   │   ├── LogoutService.php       # Servicio para cerrar sesión
│   │   ├── RegisterService.php     # Servicio para registro de usuarios
│   │   └── UserListService.php     # Servicio para listar usuarios
│   ├── auth_user.php               # Endpoint para autenticar usuarios
│   ├── check_session.php           # Endpoint para verificar sesión activa
│   ├── list_users.php              # Endpoint para listar usuarios
│   ├── logout.php                  # Endpoint para cerrar sesión
│   └── reg_user.php                # Endpoint para registrar usuarios
└── .env.example                    # Plantilla para archivo de variables de entorno
```

---

<a id="recursos-utiles"></a>
## ⛵ Recursos Útiles

- 🌐 PHP: https://www.php.net/
- 🖥️ A-frame: https://aframe.io/
- 🔐 AR JS: https://ar-js-org.github.io/AR.js-Docs/
- 📦 Mind AR JS: https://hiukim.github.io/mind-ar-js-doc/

---