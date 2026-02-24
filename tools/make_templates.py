import os
import zipfile
import tempfile
import shutil
from pathlib import Path


BASE = os.getcwd()
TPL_ROOT = os.path.join(tempfile.gettempdir(), 'localx_tpl')
Path(TPL_ROOT).mkdir(parents=True, exist_ok=True)


def write_file(path, content):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)


def zip_dir(src_dir, zip_path):
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as z:
        for root, _, files in os.walk(src_dir):
            for file in files:
                full_path = os.path.join(root, file)
                rel = os.path.relpath(full_path, src_dir)
                z.write(full_path, rel)


def reset_dir(name):
    path = os.path.join(TPL_ROOT, name)
    shutil.rmtree(path, ignore_errors=True)
    os.makedirs(path, exist_ok=True)
    return path


# PHP
php = reset_dir('php')
write_file(os.path.join(php, 'index.php'), '<?php\n\necho "Hello LocalX!";\n')
zip_dir(php, os.path.join(BASE, 'assets', 'templates', 'php.zip'))

# Laravel (minimal scaffold)
laravel = reset_dir('laravel')
write_file(os.path.join(laravel, 'artisan'), "#!/usr/bin/env php\n<?php\n\necho \"LocalX Laravel placeholder\";\n")
write_file(
    os.path.join(laravel, 'composer.json'),
    '{\n'
    '  "name": "localx/laravel-app",\n'
    '  "type": "project",\n'
    '  "require": {\n'
    '    "php": "^8.2"\n'
    '  }\n'
    '}\n',
)
write_file(
    os.path.join(laravel, 'public', 'index.php'),
    "<?php\n\necho 'Hello LocalX Laravel';\n",
)
zip_dir(laravel, os.path.join(BASE, 'assets', 'templates', 'laravel.zip'))

# Node
node = reset_dir('node')
write_file(
    os.path.join(node, 'package.json'),
    '{\n'
    '  "name": "localx-node-app",\n'
    '  "version": "1.0.0",\n'
    '  "private": true,\n'
    '  "scripts": {\n'
    '    "start": "node index.js"\n'
    '  }\n'
    '}\n',
)
write_file(os.path.join(node, 'index.js'), "console.log('LocalX Node app running');\n")
zip_dir(node, os.path.join(BASE, 'assets', 'templates', 'node.zip'))

# React (Vite)
react = reset_dir('react')
write_file(
    os.path.join(react, 'package.json'),
    '{\n'
    '  "name": "localx-react-app",\n'
    '  "version": "0.1.0",\n'
    '  "private": true,\n'
    '  "type": "module",\n'
    '  "scripts": {\n'
    '    "dev": "vite",\n'
    '    "build": "vite build",\n'
    '    "preview": "vite preview"\n'
    '  },\n'
    '  "dependencies": {\n'
    '    "react": "^18.2.0",\n'
    '    "react-dom": "^18.2.0"\n'
    '  },\n'
    '  "devDependencies": {\n'
    '    "@vitejs/plugin-react": "^4.2.0",\n'
    '    "vite": "^5.0.0"\n'
    '  }\n'
    '}\n',
)
write_file(
    os.path.join(react, 'vite.config.js'),
    "import { defineConfig } from 'vite'\n"
    "import react from '@vitejs/plugin-react'\n"
    "export default defineConfig({ plugins: [react()] })\n",
)
write_file(
    os.path.join(react, 'index.html'),
    '<!doctype html>\n<html>\n  <head>\n    <meta charset="UTF-8" />\n'
    '    <meta name="viewport" content="width=device-width, initial-scale=1.0" />\n'
    '    <title>LocalX React</title>\n  </head>\n  <body>\n'
    '    <div id="root"></div>\n    <script type="module" src="/src/main.jsx"></script>\n'
    '  </body>\n</html>\n',
)
write_file(
    os.path.join(react, 'src', 'main.jsx'),
    "import React from 'react'\n"
    "import ReactDOM from 'react-dom/client'\n"
    "import App from './App.jsx'\n"
    "import './index.css'\n"
    "ReactDOM.createRoot(document.getElementById('root')).render(<App />)\n",
)
write_file(
    os.path.join(react, 'src', 'App.jsx'),
    "export default function App() {\n"
    "  return (\n"
    "    <main style={{ fontFamily: 'sans-serif', padding: 24 }}>\n"
    "      <h1>Hello LocalX React</h1>\n"
    "    </main>\n"
    "  )\n"
    "}\n",
)
write_file(os.path.join(react, 'src', 'index.css'), "body { margin: 0; }\n")
zip_dir(react, os.path.join(BASE, 'assets', 'templates', 'react.zip'))

# Vue (Vite)
vue = reset_dir('vue')
write_file(
    os.path.join(vue, 'package.json'),
    '{\n'
    '  "name": "localx-vue-app",\n'
    '  "version": "0.1.0",\n'
    '  "private": true,\n'
    '  "type": "module",\n'
    '  "scripts": {\n'
    '    "dev": "vite",\n'
    '    "build": "vite build",\n'
    '    "preview": "vite preview"\n'
    '  },\n'
    '  "dependencies": {\n'
    '    "vue": "^3.4.0"\n'
    '  },\n'
    '  "devDependencies": {\n'
    '    "@vitejs/plugin-vue": "^5.0.0",\n'
    '    "vite": "^5.0.0"\n'
    '  }\n'
    '}\n',
)
write_file(
    os.path.join(vue, 'vite.config.js'),
    "import { defineConfig } from 'vite'\n"
    "import vue from '@vitejs/plugin-vue'\n"
    "export default defineConfig({ plugins: [vue()] })\n",
)
write_file(
    os.path.join(vue, 'index.html'),
    '<!doctype html>\n<html>\n  <head>\n    <meta charset="UTF-8" />\n'
    '    <meta name="viewport" content="width=device-width, initial-scale=1.0" />\n'
    '    <title>LocalX Vue</title>\n  </head>\n  <body>\n'
    '    <div id="app"></div>\n    <script type="module" src="/src/main.js"></script>\n'
    '  </body>\n</html>\n',
)
write_file(
    os.path.join(vue, 'src', 'main.js'),
    "import { createApp } from 'vue'\n"
    "import App from './App.vue'\n"
    "import './style.css'\n"
    "createApp(App).mount('#app')\n",
)
write_file(
    os.path.join(vue, 'src', 'App.vue'),
    '<template>\n  <main class="app">\n    <h1>Hello LocalX Vue</h1>\n  </main>\n</template>\n'
    '<style>\n.app { font-family: sans-serif; padding: 24px; }\n</style>\n',
)
write_file(os.path.join(vue, 'src', 'style.css'), "body { margin: 0; }\n")
zip_dir(vue, os.path.join(BASE, 'assets', 'templates', 'vue.zip'))

# Next.js
nextjs = reset_dir('next')
write_file(
    os.path.join(nextjs, 'package.json'),
    '{\n'
    '  "name": "localx-next-app",\n'
    '  "version": "0.1.0",\n'
    '  "private": true,\n'
    '  "scripts": {\n'
    '    "dev": "next dev",\n'
    '    "build": "next build",\n'
    '    "start": "next start"\n'
    '  },\n'
    '  "dependencies": {\n'
    '    "next": "latest",\n'
    '    "react": "latest",\n'
    '    "react-dom": "latest"\n'
    '  }\n'
    '}\n',
)
write_file(
    os.path.join(nextjs, 'pages', '_app.js'),
    "import '../styles/globals.css'\n"
    "export default function App({ Component, pageProps }) {\n"
    "  return <Component {...pageProps} />\n"
    "}\n",
)
write_file(
    os.path.join(nextjs, 'pages', 'index.js'),
    "export default function Home() {\n"
    "  return (\n"
    "    <main style={{ fontFamily: 'sans-serif', padding: 24 }}>\n"
    "      <h1>Hello LocalX Next.js</h1>\n"
    "    </main>\n"
    "  )\n"
    "}\n",
)
write_file(os.path.join(nextjs, 'styles', 'globals.css'), "body { margin: 0; }\n")
zip_dir(nextjs, os.path.join(BASE, 'assets', 'templates', 'next.zip'))

# Svelte (Vite)
svelte = reset_dir('svelte')
write_file(
    os.path.join(svelte, 'package.json'),
    '{\n'
    '  "name": "localx-svelte-app",\n'
    '  "version": "0.1.0",\n'
    '  "private": true,\n'
    '  "type": "module",\n'
    '  "scripts": {\n'
    '    "dev": "vite",\n'
    '    "build": "vite build",\n'
    '    "preview": "vite preview"\n'
    '  },\n'
    '  "dependencies": {\n'
    '    "svelte": "^4.2.0"\n'
    '  },\n'
    '  "devDependencies": {\n'
    '    "@sveltejs/vite-plugin-svelte": "^3.0.0",\n'
    '    "vite": "^5.0.0"\n'
    '  }\n'
    '}\n',
)
write_file(
    os.path.join(svelte, 'vite.config.js'),
    "import { defineConfig } from 'vite'\n"
    "import { svelte } from '@sveltejs/vite-plugin-svelte'\n"
    "export default defineConfig({ plugins: [svelte()] })\n",
)
write_file(
    os.path.join(svelte, 'index.html'),
    '<!doctype html>\n<html>\n  <head>\n    <meta charset="UTF-8" />\n'
    '    <meta name="viewport" content="width=device-width, initial-scale=1.0" />\n'
    '    <title>LocalX Svelte</title>\n  </head>\n  <body>\n'
    '    <div id="app"></div>\n    <script type="module" src="/src/main.js"></script>\n'
    '  </body>\n</html>\n',
)
write_file(
    os.path.join(svelte, 'src', 'main.js'),
    "import App from './App.svelte'\n"
    "import './app.css'\n"
    "const app = new App({ target: document.getElementById('app') })\n"
    "export default app\n",
)
write_file(
    os.path.join(svelte, 'src', 'App.svelte'),
    "<main class='app'>\n  <h1>Hello LocalX Svelte</h1>\n</main>\n"
    "<style>\n  .app { font-family: sans-serif; padding: 24px; }\n</style>\n",
)
write_file(os.path.join(svelte, 'src', 'app.css'), "body { margin: 0; }\n")
zip_dir(svelte, os.path.join(BASE, 'assets', 'templates', 'svelte.zip'))

# Nuxt
nuxt = reset_dir('nuxt')
write_file(
    os.path.join(nuxt, 'package.json'),
    '{\n'
    '  "name": "localx-nuxt-app",\n'
    '  "version": "0.1.0",\n'
    '  "private": true,\n'
    '  "scripts": {\n'
    '    "dev": "nuxt dev",\n'
    '    "build": "nuxt build",\n'
    '    "start": "nuxt start"\n'
    '  },\n'
    '  "dependencies": {\n'
    '    "nuxt": "latest"\n'
    '  }\n'
    '}\n',
)
write_file(os.path.join(nuxt, 'nuxt.config.ts'), "export default defineNuxtConfig({})\n")
write_file(
    os.path.join(nuxt, 'app.vue'),
    "<template>\n  <main style=\"font-family: sans-serif; padding: 24px;\">\n"
    "    <h1>Hello LocalX Nuxt</h1>\n  </main>\n</template>\n",
)
write_file(
    os.path.join(nuxt, 'pages', 'index.vue'),
    "<template>\n  <div>Hello LocalX Nuxt</div>\n</template>\n",
)
zip_dir(nuxt, os.path.join(BASE, 'assets', 'templates', 'nuxt.zip'))

# Angular (basic scaffold)
angular = reset_dir('angular')
write_file(
    os.path.join(angular, 'package.json'),
    '{\n'
    '  "name": "localx-angular-app",\n'
    '  "version": "0.0.0",\n'
    '  "private": true,\n'
    '  "scripts": {\n'
    '    "start": "ng serve",\n'
    '    "build": "ng build"\n'
    '  },\n'
    '  "dependencies": {\n'
    '    "@angular/animations": "^17.3.0",\n'
    '    "@angular/common": "^17.3.0",\n'
    '    "@angular/compiler": "^17.3.0",\n'
    '    "@angular/core": "^17.3.0",\n'
    '    "@angular/forms": "^17.3.0",\n'
    '    "@angular/platform-browser": "^17.3.0",\n'
    '    "@angular/platform-browser-dynamic": "^17.3.0",\n'
    '    "@angular/router": "^17.3.0",\n'
    '    "rxjs": "^7.8.1",\n'
    '    "tslib": "^2.6.2",\n'
    '    "zone.js": "^0.14.4"\n'
    '  },\n'
    '  "devDependencies": {\n'
    '    "@angular/cli": "^17.3.0",\n'
    '    "@angular/compiler-cli": "^17.3.0",\n'
    '    "@types/node": "^20.11.30",\n'
    '    "typescript": "^5.4.2"\n'
    '  }\n'
    '}\n',
)
write_file(
    os.path.join(angular, 'angular.json'),
    '{\n'
    '  "$schema": "./node_modules/@angular/cli/lib/config/schema.json",\n'
    '  "version": 1,\n'
    '  "projects": {\n'
    '    "localx-angular-app": {\n'
    '      "projectType": "application",\n'
    '      "root": "",\n'
    '      "sourceRoot": "src",\n'
    '      "prefix": "app",\n'
    '      "architect": {\n'
    '        "build": {\n'
    '          "builder": "@angular-devkit/build-angular:browser",\n'
    '          "options": {\n'
    '            "outputPath": "dist/localx-angular-app",\n'
    '            "index": "src/index.html",\n'
    '            "main": "src/main.ts",\n'
    '            "polyfills": [],\n'
    '            "tsConfig": "tsconfig.app.json",\n'
    '            "assets": ["src/favicon.ico", "src/assets"],\n'
    '            "styles": ["src/styles.css"],\n'
    '            "scripts": []\n'
    '          }\n'
    '        },\n'
    '        "serve": {\n'
    '          "builder": "@angular-devkit/build-angular:dev-server",\n'
    '          "options": {\n'
    '            "buildTarget": "localx-angular-app:build"\n'
    '          }\n'
    '        }\n'
    '      }\n'
    '    }\n'
    '  },\n'
    '  "defaultProject": "localx-angular-app"\n'
    '}\n',
)
write_file(
    os.path.join(angular, 'tsconfig.json'),
    '{\n'
    '  "compileOnSave": false,\n'
    '  "compilerOptions": {\n'
    '    "baseUrl": "./",\n'
    '    "outDir": "./dist/out-tsc",\n'
    '    "sourceMap": true,\n'
    '    "declaration": false,\n'
    '    "downlevelIteration": true,\n'
    '    "experimentalDecorators": true,\n'
    '    "module": "ES2022",\n'
    '    "moduleResolution": "node",\n'
    '    "importHelpers": true,\n'
    '    "target": "ES2022",\n'
    '    "typeRoots": ["node_modules/@types"],\n'
    '    "lib": ["ES2022", "dom"]\n'
    '  }\n'
    '}\n',
)
write_file(
    os.path.join(angular, 'tsconfig.app.json'),
    '{\n'
    '  "extends": "./tsconfig.json",\n'
    '  "compilerOptions": {\n'
    '    "outDir": "./dist/out-tsc/app",\n'
    '    "types": []\n'
    '  },\n'
    '  "files": ["src/main.ts"],\n'
    '  "include": ["src/**/*.d.ts"]\n'
    '}\n',
)
write_file(os.path.join(angular, 'src', 'main.ts'), "import { platformBrowserDynamic } from '@angular/platform-browser-dynamic'\nimport { AppModule } from './app/app.module'\nplatformBrowserDynamic().bootstrapModule(AppModule)\n")
write_file(
    os.path.join(angular, 'src', 'index.html'),
    '<!doctype html>\n<html lang="en">\n  <head>\n    <meta charset="utf-8">\n'
    '    <title>LocalX Angular</title>\n    <base href="/">\n'
    '    <meta name="viewport" content="width=device-width, initial-scale=1">\n'
    '  </head>\n  <body>\n    <app-root></app-root>\n  </body>\n</html>\n',
)
write_file(os.path.join(angular, 'src', 'styles.css'), "body { margin: 0; font-family: sans-serif; }\n")
write_file(os.path.join(angular, 'src', 'app', 'app.component.ts'), "import { Component } from '@angular/core'\n\n@Component({\n  selector: 'app-root',\n  templateUrl: './app.component.html',\n  styleUrls: ['./app.component.css']\n})\nexport class AppComponent {}\n")
write_file(os.path.join(angular, 'src', 'app', 'app.component.html'), "<main class=\"app\"><h1>Hello LocalX Angular</h1></main>\n")
write_file(os.path.join(angular, 'src', 'app', 'app.component.css'), ".app { padding: 24px; }\n")
write_file(
    os.path.join(angular, 'src', 'app', 'app.module.ts'),
    "import { NgModule } from '@angular/core'\n"
    "import { BrowserModule } from '@angular/platform-browser'\n"
    "import { AppComponent } from './app.component'\n\n"
    "@NgModule({\n  declarations: [AppComponent],\n  imports: [BrowserModule],\n  bootstrap: [AppComponent]\n})\n"
    "export class AppModule {}\n",
)
zip_dir(angular, os.path.join(BASE, 'assets', 'templates', 'angular.zip'))

# FastAPI
fastapi = reset_dir('fastapi')
write_file(
    os.path.join(fastapi, 'main.py'),
    "from fastapi import FastAPI\n\napp = FastAPI()\n\n@app.get('/')\n"
    "def read_root():\n    return {'status': 'ok', 'message': 'Hello LocalX'}\n",
)
write_file(os.path.join(fastapi, 'requirements.txt'), "fastapi\nuvicorn\n")
zip_dir(fastapi, os.path.join(BASE, 'assets', 'templates', 'fastapi.zip'))

# Django
django = reset_dir('django')
write_file(
    os.path.join(django, 'manage.py'),
    "import os\nimport sys\n\n"
    "def main():\n"
    "    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'localx_project.settings')\n"
    "    from django.core.management import execute_from_command_line\n"
    "    execute_from_command_line(sys.argv)\n\n"
    "if __name__ == '__main__':\n"
    "    main()\n",
)
write_file(os.path.join(django, 'requirements.txt'), "Django\n")
write_file(os.path.join(django, 'localx_project', '__init__.py'), "")
write_file(
    os.path.join(django, 'localx_project', 'settings.py'),
    "from pathlib import Path\n\n"
    "BASE_DIR = Path(__file__).resolve().parent.parent\n\n"
    "SECRET_KEY = 'localx-secret-key'\n"
    "DEBUG = True\n"
    "ALLOWED_HOSTS = ['*']\n\n"
    "INSTALLED_APPS = [\n"
    "    'django.contrib.admin',\n"
    "    'django.contrib.auth',\n"
    "    'django.contrib.contenttypes',\n"
    "    'django.contrib.sessions',\n"
    "    'django.contrib.messages',\n"
    "    'django.contrib.staticfiles',\n"
    "]\n\n"
    "MIDDLEWARE = [\n"
    "    'django.middleware.security.SecurityMiddleware',\n"
    "    'django.contrib.sessions.middleware.SessionMiddleware',\n"
    "    'django.middleware.common.CommonMiddleware',\n"
    "    'django.middleware.csrf.CsrfViewMiddleware',\n"
    "    'django.contrib.auth.middleware.AuthenticationMiddleware',\n"
    "    'django.contrib.messages.middleware.MessageMiddleware',\n"
    "    'django.middleware.clickjacking.XFrameOptionsMiddleware',\n"
    "]\n\n"
    "ROOT_URLCONF = 'localx_project.urls'\n\n"
    "TEMPLATES = [\n"
    "    {\n"
    "        'BACKEND': 'django.template.backends.django.DjangoTemplates',\n"
    "        'DIRS': [],\n"
    "        'APP_DIRS': True,\n"
    "        'OPTIONS': {\n"
    "            'context_processors': [\n"
    "                'django.template.context_processors.request',\n"
    "                'django.contrib.auth.context_processors.auth',\n"
    "                'django.contrib.messages.context_processors.messages',\n"
    "            ],\n"
    "        },\n"
    "    },\n"
    "]\n\n"
    "WSGI_APPLICATION = 'localx_project.wsgi.application'\n\n"
    "DATABASES = {\n"
    "    'default': {\n"
    "        'ENGINE': 'django.db.backends.sqlite3',\n"
    "        'NAME': BASE_DIR / 'db.sqlite3',\n"
    "    }\n"
    "}\n\n"
    "LANGUAGE_CODE = 'en-us'\n"
    "TIME_ZONE = 'UTC'\n"
    "USE_I18N = True\n"
    "USE_TZ = True\n\n"
    "STATIC_URL = 'static/'\n"
    "DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'\n",
)
write_file(
    os.path.join(django, 'localx_project', 'urls.py'),
    "from django.contrib import admin\nfrom django.urls import path\nfrom django.http import HttpResponse\n\n"
    "def home(_request):\n    return HttpResponse('Hello LocalX Django')\n\n"
    "urlpatterns = [\n    path('admin/', admin.site.urls),\n    path('', home),\n]\n",
)
write_file(
    os.path.join(django, 'localx_project', 'asgi.py'),
    "import os\nfrom django.core.asgi import get_asgi_application\n\n"
    "os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'localx_project.settings')\n"
    "application = get_asgi_application()\n",
)
write_file(
    os.path.join(django, 'localx_project', 'wsgi.py'),
    "import os\nfrom django.core.wsgi import get_wsgi_application\n\n"
    "os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'localx_project.settings')\n"
    "application = get_wsgi_application()\n",
)
zip_dir(django, os.path.join(BASE, 'assets', 'templates', 'django.zip'))

# WordPress (minimal placeholder)
wp = reset_dir('wordpress')
write_file(
    os.path.join(wp, 'wp-config-sample.php'),
    "<?php\n\ndefine('DB_NAME', 'wordpress');\n"
    "define('DB_USER', 'root');\n"
    "define('DB_PASSWORD', '');\n"
    "define('DB_HOST', '127.0.0.1');\n",
)
write_file(
    os.path.join(wp, 'index.php'),
    "<?php\n\necho 'Hello LocalX WordPress (placeholder)';\n",
)
os.makedirs(os.path.join(wp, 'wp-content'), exist_ok=True)
zip_dir(wp, os.path.join(BASE, 'assets', 'templates', 'wordpress.zip'))

print('templates ok')
