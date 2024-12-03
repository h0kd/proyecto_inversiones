# -*- mode: python ; coding: utf-8 -*-

from PyInstaller.utils.hooks import collect_data_files

# Incluye app.py como parte del ejecutable
datas = [
    ('templates', 'templates'),
    ('static', 'static')
]

# Incluye todas las plantillas (templates) y archivos estáticos (static) de Flask
datas += collect_data_files('templates', includes=['*'])
datas += collect_data_files('static', includes=['*'])

a = Analysis(
    ['main.py'],  # Archivo principal de arranque
    pathex=[],
    binaries=[],
    datas=datas,  # Archivos de datos necesarios para la aplicación
    hiddenimports=[],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    noarchive=False,
    optimize=0,
)

pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.datas,
    [],
    name='main',  # Nombre del ejecutable
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=False,  # Cambiar a True si necesitas la consola para depuración
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
)
