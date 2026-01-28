# OG Image TODO for Installation Tutorial

## Required OG Image

**Filename:** `2026-01-28-install-tutorial-og.png`
**Path:** `/website/blog/2026-01-28-install-tutorial-og.png`

## Design Specifications

- **Dimensions:** 1200x630px (standard Open Graph image size)
- **Format:** PNG
- **File size target:** < 300 KB

## Content Elements

### Main Text
- **Headline:** "How to Install OPC Skills in Claude Code"
- **Subtitle:** "2-Minute Tutorial"

### Visual Elements
1. **Claude Code logo** (left or center)
2. **OPC logo** (right or center)
3. **Arrow or flow indicator** showing: Marketplace → Skills
4. **Badge:** "9 Skills Available"
5. **Time indicator:** "⏱️ 2 min"

### Style Guidelines
- **Background:** Gradient matching opc.dev brand colors (purple/blue gradient)
- **Typography:**  
  - Headline: Bold, sans-serif, ~60-70px
  - Subtitle: Medium weight, ~40px
- **Color scheme:** Match existing blog OG images
  - Primary: #6366F1 (indigo)
  - Secondary: #8B5CF6 (purple)
  - Accent: #F59E0B (amber)
- **Layout:** Clean, modern, not cluttered

## Generation Options

### Option 1: Use nanobanana skill (Recommended)
```bash
# Use OPC Skills to generate the image
"Generate an OG image 1200x630px for a blog post titled 'How to Install OPC Skills in Claude Code - 2-Minute Tutorial'. Style: Modern tech blog, purple/blue gradient background, Claude Code logo on left, OPC logo on right, large bold headline text, clean and professional."
```

Then use logo-creator skill to add logos and crop to exact dimensions.

### Option 2: Design tools
- Canva (template: Social Media → Custom Size 1200x630)
- Figma
- Adobe Photoshop/Illustrator

### Option 3: AI generation services
- DALL-E 3
- Midjourney
- Stable Diffusion

## Similar Examples

Reference existing blog OG images in this directory:
- `2026-01-28-free-infrastructure-og.png`
- `2026-01-26-ralph-og.png`
- `2026-01-24-docs-skills-og.png`

Match the style and quality level of these images.

## After Generation

1. Save as `2026-01-28-install-tutorial-og.png`
2. Place in `/website/blog/` directory
3. Optimize with:
   ```bash
   # ImageMagick
   convert 2026-01-28-install-tutorial-og.png -strip -quality 85 2026-01-28-install-tutorial-og.png
   
   # Or OptiPNG
   optipng -o7 2026-01-28-install-tutorial-og.png
   ```
4. Verify dimensions: `file 2026-01-28-install-tutorial-og.png`
5. Commit to repository
6. Delete this TODO file

## Testing

Test the OG image with:
- [Twitter Card Validator](https://cards-dev.twitter.com/validator)
- [Facebook Sharing Debugger](https://developers.facebook.com/tools/debug/)
- [LinkedIn Post Inspector](https://www.linkedin.com/post-inspector/)
- [Open Graph Check](https://www.opengraphcheck.com/)

Expected preview: Title, description, and image should all display correctly.
