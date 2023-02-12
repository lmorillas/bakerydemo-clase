# Instalación Bakerydemo en el entorno de clase

Probar repositorio y corrección de errores

```bash
## Vagrantfile
Revisar

## variables de entorno

```bash
DJANGO_SETTINGS_MODULE=bakerydemo.settings.production

POSTGRES_USER=alumno
POSTGRES_PASSWORD=changeme
POSTGRES_DB=bakerypg
POSTGRES_HOST=db

DATABASE_URL=postgres://alumno:changeme@db/bakerypg
CACHE_URL=redis://redis

DJANGO_SECRET_KEY=changeme

# AWS_STORAGE_BUCKET_NAME=bakery-s3-xxxxx
# AWS_S3_REGION_NAME=us-east-1

# aws_access_key_id=xxxx
# aws_secret_access_key=yyy
# aws_session_token=xxx
# aws_region=us-east-1
```

## docker-compose.yml

```yaml
version: '3.3'

services:
  nginx:
    build: ./nginx
    restart: always
    ports:
      - 80:80
    depends_on:
      - wagtail 

  wagtail:
    build: .
    expose:
      - '8000'
    environment:
      - POSTGRES_NAME
      - POSTGRES_USER
      - POSTGRES_PASSWORD
      - POSTGRES_HOST
    depends_on:
      - db
      - redis
    # desarrollo
    # command: python manage.py runserver 0.0.0.0:8000
    # produccion -> gunicorn proyecto
    command: gunicorn bakerydemo.wsgi:application --bind 0.0.0.0:8000

  db:
    image: postgres:latest
    restart: always
    environment:
      - POSTGRES_USER
      - POSTGRES_PASSWORD
      - POSTGRES_DB
    expose:
      - '5432' 
    volumes: 
      - dbbakery:/var/lib/postgresql/data
      - ./backup:/backup
      # - ./db/init.sql:/docker-entrypoint-initdb.d/create_tables.sql

  redis:
    image: redis:latest
    restart: always
    expose:
      - '6379'

volumes:
  dbbakery:
    driver: local

```

## nginx/Dockerfile

```dockerfile
FROM nginx:1.23-alpine

RUN mkdir  /usr/share/nginx/app
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d
```

## nginx/nginx.conf

```nginx
upstream bakery {
    server wagtail:8000;
}

server {

    listen 80;  

    location / {
        proxy_pass http://bakery;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;
        proxy_redirect off;
    }

    location /static/ {
        alias /usr/share/nginx/app/static/;

    }
    location /media/ {
        alias /usr/share/nginx/app/media/;
    }
}
```

