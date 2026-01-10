#!/usr/bin/env python3
"""
image_radius.py - Apply rounded corners to images with Tailwind CSS presets.

Useful for preparing images for web use: social media, app icons, etc.
"""

import argparse
import sys
from pathlib import Path
from typing import Optional, Tuple

try:
    from PIL import Image, ImageDraw, ImageFilter, ImageOps
except ImportError:
    print("Error: Pillow is required. Install with: pip install Pillow")
    sys.exit(1)


# Tailwind CSS border-radius values in pixels (based on 16px = 1rem)
TAILWIND_RADIUS = {
    "none": 0,
    "xs": 2,      # 0.125rem
    "sm": 4,      # 0.25rem
    "md": 6,      # 0.375rem
    "lg": 8,      # 0.5rem
    "xl": 12,     # 0.75rem
    "2xl": 16,    # 1rem
    "3xl": 24,    # 1.5rem
    "4xl": 32,    # 2rem
    "full": -1,   # Special: makes circular/pill shape
}

# Platform-specific presets (size, radius)
PLATFORM_PRESETS = {
    # Social Media Profile Pictures
    "instagram-profile": {"size": (320, 320), "radius": "full", "desc": "Instagram profile picture (circular)"},
    "facebook-profile": {"size": (180, 180), "radius": "full", "desc": "Facebook profile picture"},
    "twitter-profile": {"size": (400, 400), "radius": "full", "desc": "Twitter/X profile picture"},
    "linkedin-profile": {"size": (400, 400), "radius": "full", "desc": "LinkedIn profile picture"},
    "youtube-profile": {"size": (800, 800), "radius": "full", "desc": "YouTube channel icon"},

    # Social Media Posts
    "instagram-square": {"size": (1080, 1080), "radius": "none", "desc": "Instagram square post"},
    "instagram-portrait": {"size": (1080, 1350), "radius": "none", "desc": "Instagram portrait post (4:5)"},
    "instagram-story": {"size": (1080, 1920), "radius": "none", "desc": "Instagram story (9:16)"},
    "facebook-post": {"size": (1200, 630), "radius": "none", "desc": "Facebook link preview"},
    "twitter-post": {"size": (1200, 675), "radius": "none", "desc": "Twitter/X image post (16:9)"},
    "linkedin-post": {"size": (1200, 627), "radius": "none", "desc": "LinkedIn post image"},

    # App Icons
    "ios-icon": {"size": (1024, 1024), "radius": 180, "desc": "iOS App Store icon (Apple applies mask)"},
    "ios-icon-rounded": {"size": (1024, 1024), "radius": 224, "desc": "iOS icon with rounded corners preview"},
    "android-icon": {"size": (512, 512), "radius": "full", "desc": "Android adaptive icon (circular)"},
    "android-icon-squircle": {"size": (512, 512), "radius": 108, "desc": "Android squircle icon"},
    "macos-icon": {"size": (1024, 1024), "radius": 185, "desc": "macOS app icon"},
    "favicon": {"size": (512, 512), "radius": "none", "desc": "Favicon source (will be scaled down)"},
    "favicon-rounded": {"size": (512, 512), "radius": "xl", "desc": "Favicon with subtle rounding"},

    # Web Components
    "avatar-sm": {"size": (32, 32), "radius": "full", "desc": "Small avatar"},
    "avatar-md": {"size": (48, 48), "radius": "full", "desc": "Medium avatar"},
    "avatar-lg": {"size": (96, 96), "radius": "full", "desc": "Large avatar"},
    "card-thumbnail": {"size": (400, 300), "radius": "lg", "desc": "Card thumbnail (4:3)"},
    "hero-image": {"size": (1920, 1080), "radius": "2xl", "desc": "Hero section image"},

    # Open Graph / SEO
    "og-image": {"size": (1200, 630), "radius": "none", "desc": "Open Graph image"},
    "twitter-card": {"size": (1200, 600), "radius": "none", "desc": "Twitter card image"},
}


def parse_color(color_str: str) -> Tuple[int, int, int, int]:
    """Parse color string to RGBA tuple."""
    color_str = color_str.strip().lower()

    # Named colors
    named_colors = {
        "transparent": (0, 0, 0, 0),
        "white": (255, 255, 255, 255),
        "black": (0, 0, 0, 255),
        "red": (255, 0, 0, 255),
        "green": (0, 255, 0, 255),
        "blue": (0, 0, 255, 255),
    }

    if color_str in named_colors:
        return named_colors[color_str]

    # Hex color
    if color_str.startswith("#"):
        color_str = color_str[1:]

    if len(color_str) == 3:
        # Short hex (#RGB)
        r = int(color_str[0] * 2, 16)
        g = int(color_str[1] * 2, 16)
        b = int(color_str[2] * 2, 16)
        return (r, g, b, 255)
    elif len(color_str) == 4:
        # Short hex with alpha (#RGBA)
        r = int(color_str[0] * 2, 16)
        g = int(color_str[1] * 2, 16)
        b = int(color_str[2] * 2, 16)
        a = int(color_str[3] * 2, 16)
        return (r, g, b, a)
    elif len(color_str) == 6:
        # Full hex (#RRGGBB)
        r = int(color_str[0:2], 16)
        g = int(color_str[2:4], 16)
        b = int(color_str[4:6], 16)
        return (r, g, b, 255)
    elif len(color_str) == 8:
        # Full hex with alpha (#RRGGBBAA)
        r = int(color_str[0:2], 16)
        g = int(color_str[2:4], 16)
        b = int(color_str[4:6], 16)
        a = int(color_str[6:8], 16)
        return (r, g, b, a)

    raise ValueError(f"Invalid color format: {color_str}")


def parse_size(size_str: str) -> Tuple[int, int]:
    """Parse size string (WxH) to tuple."""
    parts = size_str.lower().split("x")
    if len(parts) != 2:
        raise ValueError(f"Invalid size format: {size_str}. Use WxH (e.g., 1080x1080)")
    return (int(parts[0]), int(parts[1]))


def get_radius_pixels(radius_value, image_size: Tuple[int, int]) -> int:
    """Convert radius value to pixels."""
    if isinstance(radius_value, int):
        if radius_value == -1:  # "full" - make circular
            return min(image_size) // 2
        return radius_value

    if isinstance(radius_value, str):
        if radius_value in TAILWIND_RADIUS:
            tw_value = TAILWIND_RADIUS[radius_value]
            if tw_value == -1:
                return min(image_size) // 2
            return tw_value
        # Try parsing as integer
        try:
            return int(radius_value)
        except ValueError:
            raise ValueError(f"Unknown radius value: {radius_value}")

    return 0


def add_rounded_corners(img: Image.Image, radius: int) -> Image.Image:
    """Apply rounded corners to an image."""
    if radius <= 0:
        return img.convert("RGBA")

    # Create a mask with rounded corners
    mask = Image.new("L", img.size, 0)
    draw = ImageDraw.Draw(mask)

    # Draw rounded rectangle
    draw.rounded_rectangle(
        [(0, 0), (img.size[0] - 1, img.size[1] - 1)],
        radius=radius,
        fill=255
    )

    # Apply mask
    img = img.convert("RGBA")
    img.putalpha(mask)

    return img


def crop_to_square(img: Image.Image, position: str = "center") -> Image.Image:
    """Crop image to square."""
    width, height = img.size
    size = min(width, height)

    if position == "center":
        left = (width - size) // 2
        top = (height - size) // 2
    elif position == "top":
        left = (width - size) // 2
        top = 0
    elif position == "bottom":
        left = (width - size) // 2
        top = height - size
    elif position == "left":
        left = 0
        top = (height - size) // 2
    elif position == "right":
        left = width - size
        top = (height - size) // 2
    else:
        raise ValueError(f"Unknown crop position: {position}")

    return img.crop((left, top, left + size, top + size))


def crop_to_aspect_ratio(img: Image.Image, aspect_ratio: str, position: str = "center") -> Image.Image:
    """Crop image to specified aspect ratio."""
    parts = aspect_ratio.split(":")
    if len(parts) != 2:
        raise ValueError(f"Invalid aspect ratio: {aspect_ratio}. Use W:H (e.g., 16:9)")

    target_ratio = float(parts[0]) / float(parts[1])
    width, height = img.size
    current_ratio = width / height

    if current_ratio > target_ratio:
        # Image is wider, crop width
        new_width = int(height * target_ratio)
        new_height = height
    else:
        # Image is taller, crop height
        new_width = width
        new_height = int(width / target_ratio)

    if position == "center":
        left = (width - new_width) // 2
        top = (height - new_height) // 2
    elif position == "top":
        left = (width - new_width) // 2
        top = 0
    elif position == "bottom":
        left = (width - new_width) // 2
        top = height - new_height
    else:
        left = (width - new_width) // 2
        top = (height - new_height) // 2

    return img.crop((left, top, left + new_width, top + new_height))


def add_background(img: Image.Image, color: Tuple[int, int, int, int]) -> Image.Image:
    """Add solid background color behind transparent areas."""
    if color[3] == 0:  # Fully transparent background
        return img

    background = Image.new("RGBA", img.size, color)
    background.paste(img, (0, 0), img)
    return background


def add_border(img: Image.Image, width: int, color: Tuple[int, int, int, int], radius: int) -> Image.Image:
    """Add a border around the image."""
    if width <= 0:
        return img

    # Create new image with border
    new_size = (img.size[0] + width * 2, img.size[1] + width * 2)
    bordered = Image.new("RGBA", new_size, color)

    # Apply rounded corners to border if needed
    if radius > 0:
        bordered = add_rounded_corners(bordered, radius + width)

    # Paste original image
    bordered.paste(img, (width, width), img)

    return bordered


def add_shadow(img: Image.Image, blur: int = 10, offset: Tuple[int, int] = (5, 5),
               color: Tuple[int, int, int, int] = (0, 0, 0, 128)) -> Image.Image:
    """Add drop shadow to image."""
    if blur <= 0:
        return img

    # Calculate new image size
    padding = blur * 2 + max(abs(offset[0]), abs(offset[1]))
    new_size = (img.size[0] + padding * 2, img.size[1] + padding * 2)

    # Create shadow
    shadow = Image.new("RGBA", new_size, (0, 0, 0, 0))

    # Get alpha channel from original image
    if img.mode == "RGBA":
        alpha = img.split()[3]
    else:
        alpha = Image.new("L", img.size, 255)

    # Create shadow image
    shadow_img = Image.new("RGBA", img.size, color)
    shadow_img.putalpha(alpha)

    # Paste shadow at offset position
    shadow_x = padding + offset[0]
    shadow_y = padding + offset[1]
    shadow.paste(shadow_img, (shadow_x, shadow_y))

    # Blur the shadow
    shadow = shadow.filter(ImageFilter.GaussianBlur(blur))

    # Paste original image on top
    shadow.paste(img, (padding, padding), img)

    return shadow


def process_image(
    input_path: str,
    output_path: Optional[str] = None,
    radius: str = "lg",
    resize: Optional[Tuple[int, int]] = None,
    square: Optional[str] = None,
    aspect_ratio: Optional[str] = None,
    crop_position: str = "center",
    background: Optional[Tuple[int, int, int, int]] = None,
    border_width: int = 0,
    border_color: Tuple[int, int, int, int] = (0, 0, 0, 255),
    shadow: bool = False,
    shadow_blur: int = 10,
    shadow_offset: Tuple[int, int] = (5, 5),
    shadow_color: Tuple[int, int, int, int] = (0, 0, 0, 128),
    output_format: Optional[str] = None,
    quality: int = 95,
    preset: Optional[str] = None,
) -> str:
    """Process an image with the specified options."""

    # Load image
    img = Image.open(input_path)

    # Apply preset if specified
    if preset:
        if preset not in PLATFORM_PRESETS:
            raise ValueError(f"Unknown preset: {preset}")
        preset_config = PLATFORM_PRESETS[preset]
        resize = preset_config["size"]
        radius = preset_config["radius"]

    # Convert to RGBA for processing
    img = img.convert("RGBA")

    # Crop to square if requested
    if square:
        img = crop_to_square(img, crop_position)

    # Crop to aspect ratio if requested
    if aspect_ratio:
        img = crop_to_aspect_ratio(img, aspect_ratio, crop_position)

    # Resize if requested
    if resize:
        img = img.resize(resize, Image.Resampling.LANCZOS)

    # Calculate radius
    radius_px = get_radius_pixels(radius, img.size)

    # Apply rounded corners
    img = add_rounded_corners(img, radius_px)

    # Add border if requested
    if border_width > 0:
        img = add_border(img, border_width, border_color, radius_px)

    # Add shadow if requested
    if shadow:
        img = add_shadow(img, shadow_blur, shadow_offset, shadow_color)

    # Add background if requested
    if background:
        img = add_background(img, background)

    # Determine output path
    if not output_path:
        input_file = Path(input_path)
        suffix = f".{output_format}" if output_format else input_file.suffix
        output_path = str(input_file.with_stem(f"{input_file.stem}_rounded").with_suffix(suffix))

    # Determine output format
    if output_format:
        fmt = output_format.upper()
    else:
        fmt = Path(output_path).suffix[1:].upper()

    if fmt == "JPG":
        fmt = "JPEG"

    # Save image
    if fmt in ("JPEG", "JPG"):
        # JPEG doesn't support transparency, add white background if needed
        if img.mode == "RGBA":
            bg = Image.new("RGB", img.size, (255, 255, 255))
            bg.paste(img, (0, 0), img)
            img = bg
        img.save(output_path, format="JPEG", quality=quality, optimize=True)
    elif fmt == "WEBP":
        img.save(output_path, format="WEBP", quality=quality, lossless=(quality >= 100))
    else:
        img.save(output_path, format="PNG", optimize=True)

    return output_path


def list_presets():
    """Print available presets."""
    print("\nAvailable Platform Presets:\n")

    categories = {}
    for name, config in PLATFORM_PRESETS.items():
        # Categorize by prefix
        if "profile" in name:
            cat = "Profile Pictures"
        elif "instagram" in name or "facebook" in name or "twitter" in name or "linkedin" in name or "youtube" in name:
            cat = "Social Media Posts"
        elif "icon" in name or "favicon" in name:
            cat = "App Icons"
        elif "avatar" in name or "card" in name or "hero" in name:
            cat = "Web Components"
        else:
            cat = "SEO / Open Graph"

        if cat not in categories:
            categories[cat] = []
        categories[cat].append((name, config))

    for cat, items in categories.items():
        print(f"  {cat}:")
        for name, config in items:
            size = f"{config['size'][0]}x{config['size'][1]}"
            print(f"    {name:24} {size:12} {config['desc']}")
        print()


def list_radii():
    """Print available Tailwind radius values."""
    print("\nTailwind CSS Border Radius Values:\n")
    for name, value in TAILWIND_RADIUS.items():
        if value == -1:
            print(f"  {name:8} circular/pill shape")
        else:
            print(f"  {name:8} {value}px")
    print()


def main():
    parser = argparse.ArgumentParser(
        description="Apply rounded corners to images using Tailwind CSS presets.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s image.png                          # Apply default 'lg' radius (8px)
  %(prog)s image.png -R xl                    # Apply 'xl' radius (12px)
  %(prog)s image.png -R full                  # Make circular
  %(prog)s image.png -R 20                    # Custom 20px radius
  %(prog)s image.png --preset instagram-profile  # Instagram profile (320x320, circular)
  %(prog)s image.png --square -R full         # Crop to square, make circular
  %(prog)s image.png -r 512x512 -R 2xl        # Resize and round
  %(prog)s image.png --shadow --bg white      # Add shadow and white background
  %(prog)s image.png --format webp -q 90      # Convert to WebP at 90%% quality
        """
    )

    # Input/output
    parser.add_argument("input", nargs="?", help="Input image file")
    parser.add_argument("-o", "--output", help="Output filename")

    # Radius options
    radius_group = parser.add_argument_group("Radius Options")
    radius_group.add_argument(
        "-R", "--radius", default="lg",
        help="Border radius (Tailwind name or pixels). Default: lg (8px)"
    )

    # Size options
    size_group = parser.add_argument_group("Size Options")
    size_group.add_argument(
        "-r", "--resize", metavar="WxH",
        help="Resize output image (e.g., 1080x1080)"
    )
    size_group.add_argument(
        "--square", action="store_true",
        help="Crop image to square before processing"
    )
    size_group.add_argument(
        "--aspect-ratio", "-a", metavar="W:H",
        help="Crop to aspect ratio (e.g., 16:9, 4:3, 1:1)"
    )
    size_group.add_argument(
        "--crop-position", choices=["center", "top", "bottom", "left", "right"],
        default="center",
        help="Position for cropping. Default: center"
    )

    # Preset options
    preset_group = parser.add_argument_group("Preset Options")
    preset_group.add_argument(
        "-p", "--preset",
        help="Use platform preset (sets size and radius)"
    )
    preset_group.add_argument(
        "--list-presets", action="store_true",
        help="List available platform presets"
    )
    preset_group.add_argument(
        "--list-radii", action="store_true",
        help="List available Tailwind radius values"
    )

    # Visual effects
    effects_group = parser.add_argument_group("Visual Effects")
    effects_group.add_argument(
        "--bg", "--background", dest="background", metavar="COLOR",
        help="Background color (hex, e.g., #ffffff or white, transparent)"
    )
    effects_group.add_argument(
        "--border", type=int, default=0, metavar="WIDTH",
        help="Border width in pixels"
    )
    effects_group.add_argument(
        "--border-color", default="#000000", metavar="COLOR",
        help="Border color (hex or name). Default: black"
    )
    effects_group.add_argument(
        "--shadow", action="store_true",
        help="Add drop shadow"
    )
    effects_group.add_argument(
        "--shadow-blur", type=int, default=10, metavar="PX",
        help="Shadow blur radius. Default: 10"
    )
    effects_group.add_argument(
        "--shadow-offset", default="5,5", metavar="X,Y",
        help="Shadow offset. Default: 5,5"
    )
    effects_group.add_argument(
        "--shadow-color", default="#00000080", metavar="COLOR",
        help="Shadow color with alpha. Default: #00000080"
    )

    # Output format
    format_group = parser.add_argument_group("Output Format")
    format_group.add_argument(
        "-f", "--format", choices=["png", "jpg", "jpeg", "webp"],
        help="Output format (default: same as input)"
    )
    format_group.add_argument(
        "-q", "--quality", type=int, default=95, metavar="1-100",
        help="Quality for JPEG/WebP (1-100). Default: 95"
    )

    args = parser.parse_args()

    # Handle list commands
    if args.list_presets:
        list_presets()
        return

    if args.list_radii:
        list_radii()
        return

    # Validate input
    if not args.input:
        parser.print_help()
        sys.exit(1)

    if not Path(args.input).exists():
        print(f"Error: Input file not found: {args.input}")
        sys.exit(1)

    # Parse options
    resize = parse_size(args.resize) if args.resize else None
    background = parse_color(args.background) if args.background else None
    border_color = parse_color(args.border_color)
    shadow_color = parse_color(args.shadow_color)

    shadow_offset = tuple(int(x) for x in args.shadow_offset.split(","))

    try:
        output_path = process_image(
            input_path=args.input,
            output_path=args.output,
            radius=args.radius,
            resize=resize,
            square=args.square,
            aspect_ratio=args.aspect_ratio,
            crop_position=args.crop_position,
            background=background,
            border_width=args.border,
            border_color=border_color,
            shadow=args.shadow,
            shadow_blur=args.shadow_blur,
            shadow_offset=shadow_offset,
            shadow_color=shadow_color,
            output_format=args.format,
            quality=args.quality,
            preset=args.preset,
        )
        print(f"Saved: {output_path}")
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
