#!/usr/bin/env python3
"""
Generate iOS app icons from a source image.
"""

from PIL import Image
import os
import json

# iOS app icon sizes (in pixels) for iOS 18+
ICON_SIZES = {
    "iphone_notification_2x": 40,
    "iphone_notification_3x": 60,
    "iphone_settings_2x": 58,
    "iphone_settings_3x": 87,
    "iphone_spotlight_2x": 80,
    "iphone_spotlight_3x": 120,
    "iphone_app_2x": 120,
    "iphone_app_3x": 180,
    "app_store": 1024,
}

def generate_icons(source_image_path, output_dir):
    """Generate all required iOS app icon sizes."""
    
    # Create output directory
    os.makedirs(output_dir, exist_ok=True)
    
    # Open source image
    print(f"Opening source image: {source_image_path}")
    img = Image.open(source_image_path)
    
    # Convert to RGB if necessary
    if img.mode != 'RGB':
        img = img.convert('RGB')
    
    # Generate Contents.json
    contents = {
        "images": [],
        "info": {
            "version": 1,
            "author": "xcode"
        }
    }
    
    # Generate each icon size
    for name, size in ICON_SIZES.items():
        print(f"Generating {name} ({size}x{size})")
        
        # Resize image
        resized = img.resize((size, size), Image.Resampling.LANCZOS)
        
        # Save with appropriate filename
        if name == "app_store":
            filename = "AppIcon-1024.png"
        else:
            filename = f"AppIcon-{size}.png"
        
        output_path = os.path.join(output_dir, filename)
        resized.save(output_path, "PNG", quality=100)
        
        # Add to Contents.json
        if name == "app_store":
            contents["images"].append({
                "filename": filename,
                "idiom": "universal",
                "platform": "ios",
                "size": "1024x1024"
            })
        else:
            scale = "2x" if "_2x" in name else "3x"
            pixel_size = size // int(scale[0])
            
            if "notification" in name:
                role = "notificationCenter"
                size_str = f"{pixel_size}x{pixel_size}"
            elif "settings" in name:
                role = "settings"
                size_str = f"{pixel_size}x{pixel_size}"
            elif "spotlight" in name:
                role = "spotlight"
                size_str = f"{pixel_size}x{pixel_size}"
            else:  # app icon
                role = "primary"
                size_str = f"{pixel_size}x{pixel_size}"
            
            contents["images"].append({
                "filename": filename,
                "idiom": "iphone",
                "scale": scale,
                "size": size_str
            })
    
    # Save Contents.json
    contents_path = os.path.join(output_dir, "Contents.json")
    with open(contents_path, 'w') as f:
        json.dump(contents, f, indent=2)
    
    print(f"\n✅ Successfully generated all app icons in: {output_dir}")
    print(f"📁 Copy the entire folder to: GrabRedEnvelope/Assets.xcassets/AppIcon.appiconset/")

if __name__ == "__main__":
    source_image = "screenshots/ChatGPT Image Feb 18, 2026 at 07_32_41 PM.png"
    output_directory = "AppIcon.appiconset"
    
    if not os.path.exists(source_image):
        print(f"❌ Error: Source image not found: {source_image}")
        exit(1)
    
    generate_icons(source_image, output_directory)
