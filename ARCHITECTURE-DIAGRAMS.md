# 🏗️ Arquitectura de Seguridad - HomeLab Frontend

## 📊 Diagrama de Flujo - Deployment Pipeline

```mermaid
graph TD
    A[Developer Push to GitHub] --> B[GitHub Webhook]
    B --> C[Dokploy Detects Change]
    C --> D[Clone Repository]
    D --> E[Start Docker Build]
    
    E --> F[Install System Dependencies]
    F --> G[Install PHP Extensions]
    G --> H[Install Node.js 22.x]
    H --> I[npm install --production]
    I --> J[npm run build:config]
    
    J --> K{config.js Generated?}
    K -->|Yes| L[Delete Sensitive Files]
    K -->|No| M[Build Failed ❌]
    
    L --> N[Create .env Placeholder]
    N --> O[Set File Permissions]
    O --> P[Configure nginx + PHP-FPM]
    P --> Q[Start Container]
    
    Q --> R{Health Check}
    R -->|Pass| S[Deploy Success ✅]
    R -->|Fail| T[Rollback ❌]
    
    S --> U[Zero-Downtime Switch]
    U --> V[Production Running 🚀]
```

---

## 🔒 Diagrama de Capas de Seguridad

```mermaid
graph TB
    subgraph "Layer 1: NGINX"
        N1[Block .env]
        N2[Block config.js]
        N3[Block Directories]
        N4[Block Extensions]
        N5[Prevent PHP Execution]
    end
    
    subgraph "Layer 2: Filesystem"
        F1[chmod 600 .env]
        F2[chmod 644 config.js]
        F3[chmod 750 layout/]
        F4[chmod 750 layouts/]
        F5[chmod 750 utils/]
    end
    
    subgraph "Layer 3: Docker"
        D1[Delete .env original]
        D2[Delete .git]
        D3[Create .env placeholder]
        D4[Block node_modules/]
    end
    
    Internet[🌐 Internet] --> N1
    N1 --> F1
    F1 --> D1
    
    N2 --> F2
    F2 --> D2
    
    N3 --> F3
    F3 --> D3
    
    N4 --> F4
    F4 --> D4
    
    N5 --> F5
    
    D4 --> Protected[✅ Protected Application]
```

---

## 🚀 Diagrama de Flujo de Request HTTP

```mermaid
sequenceDiagram
    participant User as 👤 User Browser
    participant Nginx as 🛡️ NGINX
    participant PHP as 🐘 PHP-FPM
    participant App as 📱 Application
    participant DB as 🗄️ Database (Backend)
    
    User->>Nginx: GET /index.php
    Nginx->>Nginx: Check Security Rules
    
    alt Sensitive File (.env, config.js)
        Nginx-->>User: 404 Not Found ❌
    else Protected Directory (/layout/)
        Nginx-->>User: 404 Not Found ❌
    else Dangerous Extension (.ini, .log)
        Nginx-->>User: 404 Not Found ❌
    else Valid Request
        Nginx->>PHP: Forward to PHP-FPM
        PHP->>App: Process PHP
        App->>App: Load config.js (ENV_CONFIG)
        App->>DB: API Call (via router.js)
        DB-->>App: JSON Response
        App-->>PHP: Render HTML
        PHP-->>Nginx: Response
        Nginx-->>User: 200 OK ✅
    end
```

---

## 📦 Diagrama de Estructura de Archivos

```mermaid
graph LR
    Root[thepearlo_vr-website/]
    
    Root --> Dockerfile[📄 Dockerfile]
    Root --> Nginx[📄 nginx.conf]
    Root --> Package[📄 package.json]
    
    Root --> Scripts[📁 scripts/]
    Scripts --> GenConfig[generate-config.js]
    Scripts --> SecCheck[security-check.sh]
    
    Root --> JS[📁 js/]
    JS --> NpmLoader[npm-loader.js]
    JS --> Config[config.js 🔒]
    JS --> Router[router.js]
    
    Root --> Layout[📁 layout/ 🔒]
    Layout --> AppLayout[AppLayout.php]
    
    Root --> Layouts[📁 layouts/ 🔒]
    Layouts --> AdminLayout[AdminLayout.php]
    Layouts --> UserLayout[UserLayout.php]
    
    Root --> Utils[📁 utils/ 🔒]
    Root --> Pages[📁 pages/ 🔒]
    
    Root --> Docs[📁 docs/]
    Docs --> DockerSec[DOCKER-SECURITY.md]
    Docs --> Dokploy[DOKPLOY-DEPLOYMENT.md]
    Docs --> EnvConfig[ENV-CONFIG.md]
    Docs --> QuickCheck[QUICK-DEPLOYMENT-CHECKLIST.md]
    
    style Config fill:#ff6b6b
    style Layout fill:#ff6b6b
    style Layouts fill:#ff6b6b
    style Utils fill:#ff6b6b
    style Pages fill:#ff6b6b
```

---

## 🔄 Diagrama de Ciclo de Vida de config.js

```mermaid
stateDiagram-v2
    [*] --> Development: Local Dev
    
    Development --> BuildStart: npm install
    BuildStart --> PostInstall: Hook Triggered
    PostInstall --> GenerateConfig: npm run build:config
    GenerateConfig --> ReadEnv: Read .env file
    ReadEnv --> CreateConfig: Generate js/config.js
    CreateConfig --> Development: config.js ready
    
    Development --> GitPush: git push
    GitPush --> DockerBuild: Dokploy Build
    
    DockerBuild --> NpmInstallProd: npm install --production
    NpmInstallProd --> BuildConfig: npm run build:config
    BuildConfig --> ReadEnvVar: Read ENV Variables (Dokploy)
    ReadEnvVar --> GenerateConfigProd: Generate config.js
    GenerateConfigProd --> DeleteEnv: rm -f .env
    DeleteEnv --> CreatePlaceholder: touch .env
    CreatePlaceholder --> SetPerms: chmod 644 config.js
    SetPerms --> NginxBlock: nginx blocks config.js
    NginxBlock --> Production: [*]
    
    Production --> Browser: User Access
    Browser --> LoadConfig: Load window.ENV_CONFIG
    LoadConfig --> ApiCall: router.js uses API_URL
    ApiCall --> Production: Cycle Complete
```

---

## 🎯 Diagrama de Tests de Seguridad

```mermaid
graph TD
    Start[🔍 security-check.sh] --> TestEnv[Test .env]
    
    TestEnv -->|404 ✅| Pass1[1/30 Passed]
    TestEnv -->|200 ❌| Fail1[Security Breach!]
    
    Pass1 --> TestGit[Test .git/config]
    TestGit -->|404 ✅| Pass2[2/30 Passed]
    TestGit -->|200 ❌| Fail1
    
    Pass2 --> TestConfig[Test config.js]
    TestConfig -->|404 ✅| Pass3[3/30 Passed]
    TestConfig -->|200 ❌| Fail1
    
    Pass3 --> TestPackage[Test package.json]
    TestPackage -->|404 ✅| Pass4[4/30 Passed]
    TestPackage -->|200 ❌| Fail1
    
    Pass4 --> TestLayout[Test layout/]
    TestLayout -->|404 ✅| Pass5[5/30 Passed]
    TestLayout -->|200 ❌| Fail1
    
    Pass5 --> MoreTests[... 25 more tests]
    MoreTests -->|All Pass| Success[✅ 30/30 Success Rate: 100%]
    MoreTests -->|Any Fail| Fail1
    
    Success --> Report[📊 Generate Report]
    Fail1 --> Report
    
    Report --> End[🎉 Security Verified]
    
    style Success fill:#51cf66
    style Fail1 fill:#ff6b6b
```

---

## 🏭 Diagrama de Arquitectura de Producción

```mermaid
graph TB
    subgraph "Internet"
        Users[👥 Users]
    end
    
    subgraph "Dokploy Server"
        subgraph "Docker Container"
            Supervisor[📋 Supervisord]
            
            subgraph "Web Layer"
                Nginx[🛡️ NGINX :3000]
            end
            
            subgraph "Application Layer"
                PHP[🐘 PHP-FPM]
                Static[📁 Static Files]
                Config[⚙️ config.js]
            end
            
            Supervisor --> Nginx
            Supervisor --> PHP
            Nginx --> PHP
            Nginx --> Static
            Static --> Config
        end
        
        subgraph "Environment"
            EnvVars[🔐 ENV Variables]
        end
        
        EnvVars -.Injected at Runtime.-> Config
    end
    
    subgraph "Backend API"
        API[🔌 api.roepard.online]
    end
    
    Users -->|HTTPS| Nginx
    PHP -->|API Calls| API
    
    style Nginx fill:#4dabf7
    style PHP fill:#845ef7
    style Config fill:#ff6b6b
    style EnvVars fill:#51cf66
```

---

## 📈 Diagrama de Monitoreo

```mermaid
graph LR
    subgraph "Monitoring Tools"
        Security[🔒 security-check.sh]
        Logs[📋 Docker Logs]
        Metrics[📊 Dokploy Metrics]
    end
    
    subgraph "Application"
        Container[🐳 Docker Container]
    end
    
    subgraph "Alerts"
        Success[✅ All Tests Pass]
        Warning[⚠️ Performance Issues]
        Error[❌ Security Breach]
    end
    
    Security --> Container
    Logs --> Container
    Metrics --> Container
    
    Container -->|Tests Pass| Success
    Container -->|High CPU/RAM| Warning
    Container -->|404 Tests Fail| Error
    
    Success --> Dashboard[📱 Dokploy Dashboard]
    Warning --> Dashboard
    Error --> Dashboard
    
    style Success fill:#51cf66
    style Warning fill:#ffd43b
    style Error fill:#ff6b6b
```

---

## 🔄 Diagrama de CI/CD Pipeline

```mermaid
graph TD
    Dev[👨‍💻 Developer] -->|1. Code Changes| Git[📦 Git Repository]
    Git -->|2. Commit & Push| GitHub[🐙 GitHub]
    GitHub -->|3. Webhook| Dokploy[🚀 Dokploy]
    
    Dokploy -->|4. Pull Code| Clone[📥 Clone Repo]
    Clone -->|5. Start Build| Build[🔨 Docker Build]
    
    Build --> Install[📦 npm install]
    Install --> Generate[⚙️ Generate config.js]
    Generate --> Security[🔒 Apply Security]
    Security --> Test[🧪 Health Check]
    
    Test -->|Pass ✅| Deploy[🚀 Deploy]
    Test -->|Fail ❌| Rollback[↩️ Rollback]
    
    Deploy --> ZeroDown[⏱️ Zero-Downtime Switch]
    ZeroDown --> Prod[🌐 Production]
    
    Rollback --> OldVer[📦 Previous Version]
    OldVer --> Prod
    
    Prod --> Monitor[👁️ Monitoring]
    Monitor -->|Issues Detected| Alert[🚨 Alert Team]
    Monitor -->|All Good| Success[✅ Success]
    
    style Prod fill:#51cf66
    style Rollback fill:#ff6b6b
    style Success fill:#51cf66
```

---

## 📝 Leyenda de Íconos

- 🌐 **Internet/Users** - Tráfico público
- 🛡️ **NGINX** - Servidor web con seguridad
- 🐘 **PHP-FPM** - Procesador PHP
- 🐳 **Docker** - Contenedor
- 🔒 **Protected** - Archivos/directorios protegidos
- 🔐 **Environment** - Variables de entorno
- ✅ **Success** - Operación exitosa
- ❌ **Fail** - Operación fallida
- ⚠️ **Warning** - Advertencia
- 🚀 **Deploy** - Deployment en progreso
- 👁️ **Monitor** - Monitoreo activo
- 📊 **Metrics** - Métricas y estadísticas

---

*Arquitectura documentada visualmente - HomeLab VR Frontend*
*Generado el 02/01/2025*
