# 🚀 Guía de Desarrollo a Producción

## 📋 Resumen del Workflow

Este documento explica el proceso completo para pasar cambios desde la rama `development` hacia la rama `main` (producción) y deployer al servidor.

---

## 🌳 Estructura de Ramas

```
📦 Repositorio: login-erp-parque
├── 🌿 main (producción)
│   ├── 🌐 Sincronizado con servidor: 159.203.109.216
│   ├── 🔐 SSL: https://erp.parque-e.co
│   └── 🚫 NO hacer commits directos aquí
│
└── 🌱 development (desarrollo)
    ├── 💻 Para desarrollo local
    ├── ✅ Testing y validación
    └── 🔄 Base para Pull Requests
```

---

## 📍 Estado Actual

### Cambios en Development:
- ✅ **Configuración de ambiente de desarrollo**
- ✅ **Seguridad: Remoción de claves expuestas**
- ✅ **Feature: Redirección por subdominio_redireccion**
- ✅ **Mejoras en manejo de errores del frontend**

### Servicios Locales Funcionando:
- 🟢 **Backend**: http://localhost:5000 (Flask + PM2)
- 🟢 **Frontend**: http://localhost:3000 (React + Vite)
- 🟢 **Base de Datos**: Supabase remota

---

## 🔄 Proceso Completo: Development → Production

### **PASO 1: Validación en Development** ✅ *(Ya completado)*

```bash
# 1. Verificar que el código funciona localmente
cd inicio_parque
npm run dev          # Frontend en puerto 3000
python backend/app.py # Backend en puerto 5000

# 2. Hacer login con credenciales de prueba
# Usuario: Santiago
# Contraseña: 123456
# Debe redirigir a: https://prueba.parque-e.co

# 3. Verificar que los cambios están commiteados
git status
git log --oneline -3
```

### **PASO 2: Pull Request (Recomendado)**

```bash
# 1. Asegurarse de que development está actualizado
git checkout development
git pull origin development

# 2. Crear Pull Request en GitHub
# - Ir a: https://github.com/SantiagoRuizM/login-erp-parque
# - Click "Pull requests" → "New pull request"
# - Base: main ← Compare: development
# - Título: "Deploy features: subdominio_redireccion + security fixes"
# - Descripción: Lista de cambios realizados

# 3. Revisar y aprobar el PR
# 4. Hacer merge (NO delete development branch)
```

### **PASO 3: Merge Directo (Alternativo)**

```bash
# ⚠️ Solo si no usas Pull Request
git checkout main
git pull origin main
git merge development
git push origin main
```

### **PASO 4: Deploy al Servidor de Producción**

```bash
# 1. Conectar al servidor
ssh root@159.203.109.216

# 2. Navegar al directorio de la aplicación
cd /var/www/login-app

# 3. Actualizar código desde GitHub
git pull origin main

# 4. Backend: Actualizar dependencias (si es necesario)
cd backend
source venv/bin/activate
pip install -r requirements.txt

# 5. Frontend: Rebuild para producción
cd ../frontend
npm install  # Solo si package.json cambió
npm run build

# 6. Reiniciar servicios
pm2 restart login-api

# 7. Reload Nginx (si cambió configuración)
nginx -t && systemctl reload nginx

# 8. Verificar que todo funciona
curl http://localhost:5000/health
curl -I https://erp.parque-e.co
```

---

## 🔍 Verificación Post-Deploy

### **1. Health Checks**
```bash
# En el servidor
curl -s http://localhost:5000/health | jq
pm2 status
systemctl status nginx

# Desde cualquier lugar
curl -I https://erp.parque-e.co
```

### **2. Test de Funcionalidad**
1. **Acceder a**: https://erp.parque-e.co
2. **Login con**: Santiago / 123456
3. **Verificar redirección a**: https://prueba.parque-e.co
4. **Revisar logs**: `pm2 logs login-api`

### **3. Monitoreo**
```bash
# En el servidor
pm2 monit                    # Monitor en tiempo real
pm2 logs login-api --lines 50 # Últimos 50 logs
```

---

## 📁 Archivos Importantes

### **Configuración de Producción:**
```
/var/www/login-app/
├── backend/.env              # Variables de entorno producción
├── backend/ecosystem.config.js # Configuración PM2
├── frontend/dist/            # Build de React
└── frontend/.env             # Variables frontend producción
```

### **Configuración de Desarrollo:**
```
inicio_parque/
├── backend/.env.development  # Variables desarrollo
├── backend/.env.example      # Template seguro
├── frontend/.env             # Variables frontend desarrollo
└── SECURITY.md              # Guías de seguridad
```

---

## ⚠️ Reglas Importantes

### **🚫 NO HACER:**
- ❌ Commits directos a `main`
- ❌ Eliminar la rama `development`
- ❌ Subir archivos `.env` con claves reales
- ❌ Deploy sin testing previo

### **✅ SÍ HACER:**
- ✅ Siempre usar `development` para nuevos features
- ✅ Hacer Pull Request para revisión
- ✅ Testing local antes de merge
- ✅ Backup antes de deploy importante
- ✅ Verificar health checks post-deploy

---

## 🆘 Rollback de Emergencia

```bash
# Si algo sale mal en producción
ssh root@159.203.109.216

# 1. Ver commits recientes
cd /var/www/login-app
git log --oneline -5

# 2. Rollback al commit anterior
git reset --hard HEAD~1

# 3. Rebuild frontend si es necesario
cd frontend && npm run build

# 4. Reiniciar servicios
pm2 restart login-api

# 5. Verificar
curl -I https://erp.parque-e.co
```

---

## 🏗️ Arquitectura de Producción

```
🌐 Internet (HTTPS)
    ↓
🔒 Nginx (SSL termination + Reverse Proxy)
    ↓
📁 Frontend (React build estático)
    ↓ /api/*
🐍 Flask Backend (PM2 + Python:5000)
    ↓
🗃️ Supabase (Base de datos remota)
```

---

## 📞 Contactos y Recursos

- **Servidor**: 159.203.109.216
- **Dominio**: https://erp.parque-e.co
- **GitHub**: https://github.com/SantiagoRuizM/login-erp-parque
- **Monitoreo**: `pm2 monit` en el servidor

---

## 📚 Comandos de Referencia Rápida

```bash
# Desarrollo Local
git checkout development
npm run dev                    # Frontend
python backend/app.py          # Backend

# Deploy a Producción
git checkout main
git merge development
git push origin main
ssh root@159.203.109.216 "cd /var/www/login-app && git pull && cd frontend && npm run build && pm2 restart login-api"

# Monitoreo
ssh root@159.203.109.216 "pm2 status && curl -s http://localhost:5000/health"
```

---

*📝 Documento creado: $(date)*
*🤖 Generado con Claude Code - Mantener actualizado con cada deploy*