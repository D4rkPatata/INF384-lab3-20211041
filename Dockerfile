# Dockerfile del repositorio base.
# Contiene cinco malas practicas deliberadas. Cada una lleva su numero en la
# linea anterior. Corregirlas es el bloque A1 de la guia del laboratorio.

# ---------- Etapa 1: build ----------
FROM public.ecr.aws/lambda/nodejs:20 AS builder

WORKDIR /build

# Manifiesto y lock file antes que el código (defecto 2)
COPY package.json package-lock.json ./

# Instalación reproducible desde el lock file, incluye devDependencies
# porque esbuild se necesita para el build (defecto 3)
RUN npm ci

# Recién ahora el código fuente
COPY src ./src

# Empaqueta handler + dependencias en un único archivo: dist/handler.js
RUN npm run build

# ---------- Etapa 2: runtime ----------
FROM public.ecr.aws/lambda/nodejs:20

# Solo el artefacto empaquetado. Sin node_modules, sin esbuild,
# sin devDependencies, sin gestor de paquetes del sistema (defecto 5).
COPY --from=builder /build/dist/handler.js ${LAMBDA_TASK_ROOT}/handler.js

CMD ["handler.handler"]