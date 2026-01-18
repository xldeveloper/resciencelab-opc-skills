# Example: Creating OPC Skills Logo

This example shows the complete logo creation workflow for the OPC Skills website (opc.dev).

## Discovery Phase

**User:** Create a logo for https://opc.dev/

**Agent:** I'd be happy to help create a logo for OPC Skills. Let me ask a few questions:

1. **Style preference?** Looking at the site, it seems tech-focused. Would you prefer:
   - Pixel art / 8-bit retro
   - Minimalist / flat design
   - Something else?

2. **Aspect ratio?** 1:1 square (for favicon/icons)?

3. **Colors?** Monochrome (black & white) or specific colors?

4. **Any reference images** to draw inspiration from?

**User:** Please refer to `/Users/yilin/Desktop/mule_logo.svg` - it's a pixel art style

**Agent:** *[Reads reference file - pixel art mule made of 1x1 pixel rectangles]*

Got it! The reference is a classic pixel art style with:
- Black pixels on white background
- 8-bit retro aesthetic
- Simple, recognizable silhouette

I'll generate 20 pixel art logo variations for OPC Skills.

---

## Generation Phase

**Agent:** Generating 20 logo variations...

*[Uses nano-banana-pro to generate logos with prompts like:]*
- "Pixel art robot head logo, 8-bit retro style, black pixels on white background"
- "Pixel art crowned person, 8-bit style, solopreneur king"
- "Pixel art lightning bolt, 8-bit, black on white"
- etc.

*[Creates HTML preview and opens in Chrome DevTools]*

Here are 20 logo options. Which ones do you like?

| # | Concept |
|---|---------|
| 01 | Robot Head |
| 02 | Circuit O |
| 03 | Lightning |
| ... | ... |
| 09 | Crowned Person |
| ... | ... |

---

## Iteration Phase

**User:** #09 looks great, please create 20 more logos similar to it.

**Agent:** Generating 20 variations of the "Crowned Person" concept...

*[Generates variations:]*
- Front facing royal figure
- Side profile with crown
- Chess king piece
- Person with floating crown
- Crowned letter "O"
- etc.

*[Updates HTML preview]*

Here are 20 variations of logo #09. Which do you prefer?

**User:** Original #09 looks good, let's make it better fit a 1:1 square

---

## Finalization Phase

**Agent:** I'll crop the original #09 to remove margins and center it in a 1:1 square.

```bash
python3 scripts/crop_logo.py logo-09.png logo-09-cropped.png
```

Output:
- Original: 1024x1024
- Content: 539x833
- Output: 833x833

*[Shows comparison of original vs cropped]*

**User:** Great! Now please remove the background and convert to SVG

**Agent:** 

**Step 1: Remove background**
```bash
python3 scripts/remove_bg.py logo-09-cropped.png logo-09-nobg.png
```
Success! Background removed.

**Step 2: Convert to SVG**
```bash
python3 scripts/vectorize.py logo-09-cropped.png logo-09.svg
```
Success! Vectorized to SVG.

---

## Final Deliverables

```
## Final Logo Assets

| File | Description | Size |
|------|-------------|------|
| logo-09.png | Original | 1024x1024, ~140 KB |
| logo-09-cropped.png | No margins, 1:1 | 833x833, ~85 KB |
| logo-09-nobg.png | Transparent background | 833x833, ~67 KB |
| logo-09.svg | Vector (scalable) | ~18 KB |

All files saved to: /project/website/logos/
```

The SVG is now:
- Infinitely scalable without quality loss
- Much smaller file size
- Perfect for web use, favicons, and print

---

## Key Takeaways

1. **Start with reference** - Having an example style makes iteration faster
2. **Generate many options** - 20 variations gives good variety
3. **Iterate on favorites** - Don't settle, refine the best options
4. **Crop before vectorizing** - Removes unnecessary whitespace
5. **Deliver multiple formats** - PNG, transparent PNG, and SVG cover all use cases
