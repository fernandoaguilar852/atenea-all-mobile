# 🔍 Validación de Servicios - ATENEA Mobile

## Checklist de Validación

- [ ] Auth - Login
- [ ] Auth - Refresh Token
- [ ] Dashboard - Estadísticas
- [ ] Chat IA - Query
- [ ] Reportes - Ventas
- [ ] Reportes - Venta Detallada
- [ ] Reportes - Inventario Consumido
- [ ] Reportes - Arqueo de Caja
- [ ] Reportes - Stock de Productos
- [ ] Reportes - Costo-Beneficio

---

## 1️⃣ Auth - Login

### API Endpoint
```
POST /v1/pos/login
```

### Request
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

### Response
```json
{
  "headers": {...},
  "messageResponse": {...},
  "data": {
    "accessToken": "eyJ...",
    "refreshToken": "eyJ...",
    "user": {
      "id": 1,
      "nombre": "John Doe",
      "email": "user@example.com",
      "clienteId": 2,
      "rolId": 1
    }
  }
}
```

### Modelo - VALIDANDO...
