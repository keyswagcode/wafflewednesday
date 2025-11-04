#!/usr/bin/env python3
"""
Generate a cute cartoon waffle app icon with purple background
"""

from PIL import Image, ImageDraw
import math

def create_waffle_icon(size=1024):
    """Create a cartoon waffle icon on purple background"""

    # Create image with purple gradient background
    img = Image.new('RGB', (size, size))
    draw = ImageDraw.Draw(img)

    # Draw purple gradient background
    for y in range(size):
        # Purple gradient from light to dark
        r = int(150 - (y / size) * 30)
        g = int(100 - (y / size) * 40)
        b = int(200 - (y / size) * 40)
        draw.line([(0, y), (size, y)], fill=(r, g, b))

    # Waffle circle parameters
    center_x, center_y = size // 2, size // 2
    waffle_radius = int(size * 0.38)

    # Draw waffle shadow
    shadow_offset = int(size * 0.02)
    draw.ellipse(
        [(center_x - waffle_radius + shadow_offset, center_y - waffle_radius + shadow_offset),
         (center_x + waffle_radius + shadow_offset, center_y + waffle_radius + shadow_offset)],
        fill=(60, 40, 80)
    )

    # Draw waffle base circle (golden brown)
    draw.ellipse(
        [(center_x - waffle_radius, center_y - waffle_radius),
         (center_x + waffle_radius, center_y + waffle_radius)],
        fill=(235, 195, 100)
    )

    # Draw waffle grid pattern
    grid_size = int(size * 0.05)
    grid_color = (190, 150, 70)

    for x in range(-waffle_radius, waffle_radius, grid_size):
        for y in range(-waffle_radius, waffle_radius, grid_size):
            # Check if point is within circle
            if math.sqrt(x*x + y*y) < waffle_radius - grid_size//2:
                # Draw grid square
                draw.rectangle(
                    [(center_x + x, center_y + y),
                     (center_x + x + grid_size - 2, center_y + y + grid_size - 2)],
                    fill=grid_color
                )

    # Draw highlight shine
    shine_offset = int(size * 0.08)
    shine_size = int(size * 0.12)
    draw.ellipse(
        [(center_x - waffle_radius + shine_offset, center_y - waffle_radius + shine_offset),
         (center_x - waffle_radius + shine_offset + shine_size, center_y - waffle_radius + shine_offset + shine_size)],
        fill=(255, 255, 200, 150)
    )

    return img

def main():
    print("Generating WaffleWednesday app icon...")

    # Generate 1024x1024 icon
    icon = create_waffle_icon(1024)

    # Save to AppIcon.appiconset directory
    output_path = "/Users/keyanchang/Desktop/WaffleWednesday/WaffleWednesday/Assets.xcassets/AppIcon.appiconset/icon-1024.png"
    icon.save(output_path, "PNG")
    print(f"✓ Saved 1024x1024 icon to {output_path}")

    print("✓ Icon generation complete!")

if __name__ == "__main__":
    main()
