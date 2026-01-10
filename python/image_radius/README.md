# image_radius

A Python script for applying rounded corners to images using Tailwind CSS border-radius presets. Perfect for preparing images for web use: social media, app icons, profile pictures, and more.

## Installation

Requires Python 3.8+ and Pillow:

```bash
pip install Pillow
```

## Basic Usage

```bash
python image_radius.py input.png                    # Apply default 'lg' radius (8px)
python image_radius.py input.png -o output.png      # Specify output filename
python image_radius.py input.png -R xl              # Apply 'xl' radius (12px)
python image_radius.py input.png -R 20              # Custom 20px radius
python image_radius.py input.png -R full            # Make circular (requires square)
```

## Options

### Radius Options

| Option | Description |
|--------|-------------|
| `-R, --radius` | Border radius (Tailwind name or pixels). Default: `lg` |

**Tailwind CSS Radius Values:**

| Name | Pixels | Description |
|------|--------|-------------|
| `none` | 0px | No rounding |
| `xs` | 2px | Extra small |
| `sm` | 4px | Small |
| `md` | 6px | Medium |
| `lg` | 8px | Large (default) |
| `xl` | 12px | Extra large |
| `2xl` | 16px | 2x large |
| `3xl` | 24px | 3x large |
| `4xl` | 32px | 4x large |
| `full` | 50% | Circular/pill shape |

### Size Options

| Option | Description |
|--------|-------------|
| `-r, --resize WxH` | Resize output image (e.g., `1080x1080`) |
| `--square` | Crop image to square before processing |
| `-a, --aspect-ratio W:H` | Crop to aspect ratio (e.g., `16:9`, `4:3`) |
| `--crop-position` | Position for cropping: `center`, `top`, `bottom`, `left`, `right` |

### Platform Presets

Use `--preset` to quickly apply optimized settings for common platforms:

```bash
python image_radius.py photo.png --preset instagram-profile
python image_radius.py photo.png -p ios-icon
```

**Profile Pictures:**
| Preset | Size | Radius | Description |
|--------|------|--------|-------------|
| `instagram-profile` | 320x320 | full | Instagram profile (circular) |
| `facebook-profile` | 180x180 | full | Facebook profile |
| `twitter-profile` | 400x400 | full | Twitter/X profile |
| `linkedin-profile` | 400x400 | full | LinkedIn profile |
| `youtube-profile` | 800x800 | full | YouTube channel icon |

**Social Media Posts:**
| Preset | Size | Radius | Description |
|--------|------|--------|-------------|
| `instagram-square` | 1080x1080 | none | Instagram square post |
| `instagram-portrait` | 1080x1350 | none | Instagram portrait (4:5) |
| `instagram-story` | 1080x1920 | none | Instagram story (9:16) |
| `facebook-post` | 1200x630 | none | Facebook link preview |
| `twitter-post` | 1200x675 | none | Twitter/X image (16:9) |
| `linkedin-post` | 1200x627 | none | LinkedIn post |

**App Icons:**
| Preset | Size | Radius | Description |
|--------|------|--------|-------------|
| `ios-icon` | 1024x1024 | 180px | iOS App Store icon |
| `ios-icon-rounded` | 1024x1024 | 224px | iOS with visible rounding |
| `android-icon` | 512x512 | full | Android circular icon |
| `android-icon-squircle` | 512x512 | 108px | Android squircle |
| `macos-icon` | 1024x1024 | 185px | macOS app icon |
| `favicon` | 512x512 | none | Favicon source |
| `favicon-rounded` | 512x512 | xl | Rounded favicon |

**Web Components:**
| Preset | Size | Radius | Description |
|--------|------|--------|-------------|
| `avatar-sm` | 32x32 | full | Small avatar |
| `avatar-md` | 48x48 | full | Medium avatar |
| `avatar-lg` | 96x96 | full | Large avatar |
| `card-thumbnail` | 400x300 | lg | Card thumbnail (4:3) |
| `hero-image` | 1920x1080 | 2xl | Hero section image |

**SEO / Open Graph:**
| Preset | Size | Radius | Description |
|--------|------|--------|-------------|
| `og-image` | 1200x630 | none | Open Graph image |
| `twitter-card` | 1200x600 | none | Twitter card image |

### Visual Effects

| Option | Description |
|--------|-------------|
| `--bg, --background COLOR` | Background color (`#ffffff`, `white`, `transparent`) |
| `--border WIDTH` | Border width in pixels |
| `--border-color COLOR` | Border color (hex or name) |
| `--shadow` | Add drop shadow |
| `--shadow-blur PX` | Shadow blur radius (default: 10) |
| `--shadow-offset X,Y` | Shadow offset (default: 5,5) |
| `--shadow-color COLOR` | Shadow color with alpha (default: `#00000080`) |

### Output Format

| Option | Description |
|--------|-------------|
| `-o, --output FILENAME` | Output filename |
| `-f, --format FORMAT` | Output format: `png`, `jpg`, `jpeg`, `webp` |
| `-q, --quality 1-100` | Quality for JPEG/WebP (default: 95) |

## Examples

### Create a circular profile picture
```bash
python image_radius.py photo.jpg --square -R full -o profile.png
```

### Prepare an iOS app icon
```bash
python image_radius.py logo.png --preset ios-icon-rounded -o AppIcon.png
```

### Instagram square post with subtle rounding
```bash
python image_radius.py photo.jpg -r 1080x1080 -R md --bg white -o instagram.jpg
```

### Avatar with shadow
```bash
python image_radius.py face.png --preset avatar-lg --shadow --bg white -o avatar.png
```

### Convert to WebP with rounded corners
```bash
python image_radius.py hero.png -R 2xl -f webp -q 90 -o hero.webp
```

### Crop to 16:9 with rounding
```bash
python image_radius.py photo.jpg --aspect-ratio 16:9 -R xl -o thumbnail.png
```

### Add border and shadow
```bash
python image_radius.py logo.png -R xl --border 3 --border-color "#3b82f6" --shadow -o styled.png
```

## Listing Available Options

```bash
python image_radius.py --list-presets    # Show all platform presets
python image_radius.py --list-radii      # Show Tailwind radius values
```

## Tips

1. **Circular images require square aspect ratio** - Use `--square` or `--aspect-ratio 1:1` before applying `full` radius.

2. **PNG for transparency** - Use PNG output when you need transparent corners. JPEG will fill transparent areas with white.

3. **WebP for web** - WebP offers better compression than PNG/JPEG with transparency support.

4. **Background color** - Add `--bg white` or similar when converting to JPEG to control the background color.

5. **Shadow adds padding** - The shadow effect increases the image dimensions to accommodate the blur and offset.
