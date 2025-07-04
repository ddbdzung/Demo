# nestjs-crud – TODO Checklist

A living checklist of best-practice enhancements still **missing** from
this repository. Tick the boxes as you go! 👍

## 1️⃣ Base Project Hygiene
- [X] **Add Commitlint / Conventional Commit hooks** (husky + @commitlint)
- [X] **Add CODEOWNERS** file
- [X] **Setup GitHub Actions CI** (lint, test, build)
- [ ] **Configure Renovate / Dependabot**
- [X] **Add LICENSE** (e.g. MIT)

## 2️⃣ Testing
- [ ] **Unit test coverage** for each service / controller
- [ ] **Integration tests** with an in-memory DB
- [ ] **e2e test matrix** in CI

## 3️⃣ Documentation
- [ ] **Auto-generated API docs** (Swagger/OpenAPI)
- [ ] **ADR folder** (Architecture Decision Records)
- [ ] **Code of Conduct**

## 4️⃣ Code Quality
- [ ] **Enable ESLint “strict-mode” rules**
- [X] **Add Prettier-check to pre-commit**
- [ ] **Add SonarQube / sonarcloud scan**
- [ ] **Setup Husky pre-push “pnpm test”**

## 5️⃣ Configuration & Environment
- [ ] **.env.example** template
- [ ] **Validate env vars** with @nestjs/config + Joi
- [ ] **Dockerfile + docker-compose** for local dev
- [ ] **Helm chart / k8s manifests**

## 6️⃣ Security
- [ ] **Helmet** middleware
- [ ] **Rate-limiting** (e.g. @nestjs/throttler)
- [ ] **Audit scripts** (`pnpm audit` in CI)
- [ ] **OWASP dependency-check** or snyk action

## 7️⃣ Logging & Observability
- [ ] **Structured logging** (pino / nest-winston)
- [ ] **Distributed tracing** (OpenTelemetry)
- [ ] **Health-check endpoint** (`@nestjs/terminus`)
- [ ] **Metrics endpoint** (Prometheus)

## 8️⃣ Database Layer
- [ ] **Prisma / TypeORM migrations** automated
- [ ] **Seed scripts**
- [ ] **Transaction tests**

## 9️⃣ API Design
- [ ] **Versioned routes** (`/v1`)
- [ ] **Global exception filter**
- [ ] **Validation pipe** with class-validator
- [ ] **Request-response interceptors for logging**

_Keep this list updated as the project evolves!_
