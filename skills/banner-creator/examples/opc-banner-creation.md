# Example: OPC Skills Banner Creation

This documents the actual banner creation process for opc.dev.

## Requirements Gathered

**Project:** OPC Skills (opc.dev)
**Purpose:** GitHub README banner
**Target size:** 1280×640 (2:1 ratio)
**Style:** Pixel art, matching existing crowned king logo
**Text:** "opc.dev" and "Agent Skills"
**Character:** Pixel art crowned king from logo

## Generation Process

### Round 1: Initial 16:9 Banners

First generated 20 banners at 16:9 ratio with character consistency:

```
nano-banana-pro___generate_image(
  prompt: "Wide pixel art banner featuring a pixel art crowned solopreneur king character, 
           8-bit retro game style, the character is coding on a laptop with a golden crown, 
           text 'opc.dev' prominently displayed, 'Agent Skills' as tagline, 
           dark purple/blue gradient background with pixel stars",
  aspectRatio: "16:9",
  image: "/path/to/opc-logo.svg",
  fileName: ".skill-archive/banner-creator/2026-01-19-opc-banner/banner-01.png"
)
```

### Round 2: 2:1 GitHub Format

User noted GitHub banners work best at 2:1 ratio. Generated 20 more at 21:9 (widest available):

```
nano-banana-pro___generate_image(
  prompt: "Ultra-wide pixel art banner, 8-bit retro game style, 
           pixel crowned king character on the left side holding a laptop, 
           'opc.dev' in large pixel font, 'Agent Skills' subtitle, 
           gradient background from deep purple to blue, pixel art style throughout",
  aspectRatio: "21:9",
  image: "/path/to/opc-logo.svg",
  fileName: ".skill-archive/banner-creator/2026-01-19-opc-banner/banner-21-01.png"
)
```

### Cropping to 2:1

Cropped all 21:9 banners to 2:1 (1280×640):

```bash
python3 scripts/crop_banner.py banner-21-01.png banner-21-01-cropped.png --ratio 2:1 --width 1280
```

## User Selection

User selected **#03** from the cropped 2:1 banners:
- Featured pixel crowned king with laptop
- "opc.dev" text clearly visible
- "Agent Skills" tagline included
- Clean dark gradient background

## Final Deliverables

| File | Size | Description |
|------|------|-------------|
| banner-03.png | 2016×864 | Original 21:9 |
| banner-03-cropped.png | 1280×640 | Final 2:1 GitHub banner |

## Integration

Banner was added to:
1. `README.md` - Centered at top
2. `website/worker.js` - Hero section with max-width: 560px

```markdown
<!-- README.md -->
<p align="center">
  <img src="website/opc-banner.png" alt="OPC Skills" width="640">
</p>
```

## Tips Learned

1. **Generate wider, crop narrower** - 21:9 gives flexibility to crop to any target
2. **Character consistency** - Use `image` parameter to maintain logo character
3. **Text placement** - Request text on specific side if cropping will occur
4. **Multiple rounds** - First round explores styles, second round refines winner
