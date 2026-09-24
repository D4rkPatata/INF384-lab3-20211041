# Dockerfile del repositorio base.
# Contiene cinco malas practicas deliberadas. Cada una lleva su numero en la
# linea anterior. Corregirlas es el bloque A1 de la guia del laboratorio.

# ---------- Etapa de build ----------
# defecto 1 corregido: version fija (no "latest")
FROM public.ecr.aws/lambda/nodejs:20 AS build

WORKDIR /build

# defecto 2 corregido: manifiesto y lock file copiados e instalados
# antes que el codigo de la aplicacion
COPY package.json package-lock.json ./

# defecto 3 corregido: instalacion reproducible desde el lock file
# (incluye devDependencies porque esbuild se usa mas abajo)
RUN npm ci

# defecto 4 corregido: sin ENV con credenciales. Si la app necesita
# DB_PASSWORD, se inyecta en runtime (config de Lambda / Secrets Manager),
# nunca declarado aqui.

# defecto 5 corregido: sin RUN dnf install de herramientas de depuracion;
# no se necesitan para instalar dependencias ni para empaquetar con esbuild.

COPY src ./src

### NO TOCAR DE ACA EN ADELANTE, CONSIDEREN QUE EL WORKDIR DEBE SER /build
RUN npx esbuild src/handler.js \
      --bundle --platform=node --target=node20 \
      --outfile=dist/handler.js

# Etapa final: recibe unicamente el artefacto empaquetado.
# El arbol de node_modules se queda en la etapa anterior.
FROM public.ecr.aws/lambda/nodejs:20 AS runtime
COPY --from=build /build/dist/handler.js ${LAMBDA_TASK_ROOT}/

CMD ["handler.handler"]