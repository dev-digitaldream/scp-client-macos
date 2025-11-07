#!/usr/bin/env python3
"""
Génère une icône pour l'application SCP Client
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_icon(size):
    """Crée une icône avec un serveur et un dossier"""
    # Créer une image avec fond bleu dégradé
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Dessiner un fond circulaire bleu
    margin = size // 10
    draw.ellipse([margin, margin, size-margin, size-margin],
                 fill=(41, 128, 185, 255))

    # Dessiner un serveur (rectangle avec lignes)
    server_w = size // 3
    server_h = size // 2
    server_x = size // 4
    server_y = size // 4

    # Corps du serveur (gris foncé)
    draw.rectangle([server_x, server_y, server_x + server_w, server_y + server_h],
                   fill=(52, 73, 94, 255), outline=(236, 240, 241, 255), width=max(1, size//64))

    # Lignes du serveur
    line_spacing = server_h // 4
    for i in range(1, 4):
        y = server_y + i * line_spacing
        draw.line([server_x, y, server_x + server_w, y],
                 fill=(236, 240, 241, 255), width=max(1, size//64))

    # Dessiner un dossier
    folder_w = size // 2.5
    folder_h = size // 3
    folder_x = size - folder_w - size // 6
    folder_y = size - folder_h - size // 6

    # Tab du dossier
    tab_w = folder_w // 3
    tab_h = folder_h // 4
    draw.rectangle([folder_x, folder_y - tab_h, folder_x + tab_w, folder_y],
                   fill=(243, 156, 18, 255))

    # Corps du dossier
    draw.rectangle([folder_x, folder_y, folder_x + folder_w, folder_y + folder_h],
                   fill=(241, 196, 15, 255), outline=(243, 156, 18, 255), width=max(1, size//64))

    # Flèches de transfert (entre serveur et dossier)
    arrow_y = size // 2
    arrow_start_x = server_x + server_w + size // 20
    arrow_end_x = folder_x - size // 20
    arrow_mid_x = (arrow_start_x + arrow_end_x) // 2

    # Flèche vers le haut (upload)
    draw.line([arrow_mid_x, arrow_y + size//12, arrow_mid_x, arrow_y - size//12],
             fill=(255, 255, 255, 255), width=max(2, size//32))
    draw.polygon([arrow_mid_x, arrow_y - size//12,
                  arrow_mid_x - size//20, arrow_y - size//24,
                  arrow_mid_x + size//20, arrow_y - size//24],
                 fill=(255, 255, 255, 255))

    # Flèche vers le bas (download)
    draw.line([arrow_mid_x + size//16, arrow_y - size//12, arrow_mid_x + size//16, arrow_y + size//12],
             fill=(255, 255, 255, 255), width=max(2, size//32))
    draw.polygon([arrow_mid_x + size//16, arrow_y + size//12,
                  arrow_mid_x + size//16 - size//20, arrow_y + size//24,
                  arrow_mid_x + size//16 + size//20, arrow_y + size//24],
                 fill=(255, 255, 255, 255))

    return img

# Créer toutes les tailles nécessaires
sizes = {
    'icon_16x16.png': 16,
    'icon_16x16@2x.png': 32,
    'icon_32x32.png': 32,
    'icon_32x32@2x.png': 64,
    'icon_128x128.png': 128,
    'icon_128x128@2x.png': 256,
    'icon_256x256.png': 256,
    'icon_256x256@2x.png': 512,
    'icon_512x512.png': 512,
    'icon_512x512@2x.png': 1024
}

output_dir = 'SCPClient/Assets.xcassets/AppIcon.appiconset'

print("Génération des icônes...")
for filename, size in sizes.items():
    icon = create_icon(size)
    output_path = os.path.join(output_dir, filename)
    icon.save(output_path, 'PNG')
    print(f"✓ {filename} ({size}x{size})")

print("\n✅ Toutes les icônes ont été générées !")
