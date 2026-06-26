# Tasks: SCRUM-42

> Este archivo es generado automáticamente por OpenSpec al ejecutar `/plan-change`.
> Es la fuente de verdad para las tareas a implementar. NO EDITAR manualmente sin actualizar OpenSpec.

## Resumen del cambio

Implementar registro de usuarios con email y contraseña.

## Tasks

### Task 1: Create User entity and migration

- [ ] Write User entity test
- [ ] Implement User entity with fields: id, email, password_hash, created_at, updated_at
- [ ] Create database migration for users table
- [ ] Update docs/data-model.md
- Priority: High
- Layer: Backend (Data)

### Task 2: Implement POST /api/v1/auth/register endpoint

- [ ] Write integration test for register endpoint
- [ ] Implement request validation (email format, password strength)
- [ ] Implement password hashing with bcrypt
- [ ] Implement user creation service
- [ ] Return 201 with user data (excluding password)
- [ ] Return 422 for validation errors
- [ ] Return 409 for duplicate email
- [ ] Update docs/api-spec.yml
- Priority: High
- Layer: Backend (API)

### Task 3: Create registration form component

- [ ] Write component test for RegistrationForm
- [ ] Implement form with email, password, confirm password fields
- [ ] Implement client-side validation
- [ ] Implement loading, error and success states
- [ ] Connect to POST /api/v1/auth/register
- Priority: High
- Layer: Frontend (UI)

### Task 4: Add password strength indicator

- [ ] Write unit test for password strength logic
- [ ] Implement password strength utility
- [ ] Integrate indicator into RegistrationForm
- Priority: Medium
- Layer: Frontend (UI)
