# Dockerfile del repositorio base.
# Contiene cinco malas practicas deliberadas. Cada una lleva su numero en la
# linea anterior. Corregirlas es el bloque A1 de la guia del laboratorio.

FROM public.ecr.aws/lambda/nodejs:20 AS builder

WORKDIR /build

# Copiamos primero el manifiesto y el lock file (defecto 2)
COPY package.json package-lock.json ./

# Instalación reproducible a partir del lock file (defecto 3)
RUN npm ci

# Recién ahora copiamos el código fuente
COPY src ./src

RUN npm run build

FROM public.ecr.aws/lambda/nodejs:20

# Solo se copia el artefacto empaquetado: node_modules resueltos + código.
COPY --from=builder /build/dist/handler.js ${LAMBDA_TASK_ROOT}/handler.js

# Sin ENV con credenciales

CMD ["src/handler.handler"]