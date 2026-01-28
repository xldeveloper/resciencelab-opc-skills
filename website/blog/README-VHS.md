# Recording Installation GIF with VHS

This directory contains a VHS tape file for generating the OPC Skills installation tutorial GIF.

## What is VHS?

[VHS](https://github.com/charmbracelet/vhs) is a terminal recorder by Charm Bracelet that generates GIFs from scripted terminal sessions. It ensures consistent, reproducible recordings that can be version-controlled.

## Prerequisites

Install VHS and its dependencies:

### macOS
```bash
brew install vhs
```

### Linux (Arch)
```bash
pacman -S vhs
```

### Linux (Ubuntu/Debian)
```bash
# Install dependencies first
sudo apt install ttyd ffmpeg

# Install VHS
go install github.com/charmbracelet/vhs@latest
```

### Windows
```bash
scoop install vhs
```

## Generate the GIF

From the `website/blog` directory:

```bash
cd website/blog
vhs install-walkthrough.tape
```

This will create `install-walkthrough.gif` in the current directory (approximately 2-3 MB).

## Output

- **File:** `install-walkthrough.gif`
- **Duration:** ~30-40 seconds
- **Size:** ~2-3 MB (unoptimized)
- **Dimensions:** 1400x800px

## Optimization

Compress the GIF for web delivery:

```bash
# Install gifsicle (if not already installed)
brew install gifsicle  # macOS
sudo apt install gifsicle   # Linux

# Optimize the GIF
gifsicle -O3 --colors 256 install-walkthrough.gif -o install-walkthrough-optimized.gif
```

Expected file size after optimization: **800 KB - 1.5 MB** (40-60% reduction).

## Customization

Edit `install-walkthrough.tape` to adjust the recording:

### Visual Settings
```tape
Set FontSize 24          # Terminal font size
Set Width 1400          # Terminal width in pixels
Set Height 800          # Terminal height in pixels
Set Padding 20          # Padding around terminal
Set Theme "Dracula"     # Color scheme (Dracula, Monokai, Nord, etc.)
```

### Playback Settings
```tape
Set PlaybackSpeed 1.0   # Animation speed (1.0 = normal, 0.5 = slow, 2.0 = fast)
Set TypingSpeed 100ms   # How fast text appears to type
```

### Timing
```tape
Sleep 1s                # Pause for 1 second
Sleep 500ms             # Pause for 500 milliseconds
```

## Troubleshooting

### Error: `ttyd` not found
```bash
# macOS
brew install ttyd

# Linux
sudo apt install ttyd
```

### Error: `ffmpeg` not found
```bash
# macOS
brew install ffmpeg

# Linux
sudo apt install ffmpeg
```

### GIF file too large
1. Reduce terminal dimensions:
   ```tape
   Set Width 1200   # Smaller width
   Set Height 700   # Smaller height
   ```

2. Decrease font size:
   ```tape
   Set FontSize 20  # Smaller font
   ```

3. Use gifsicle optimization (see above)

### Colors look washed out
Try a different theme:
```tape
Set Theme "Monokai"     # Alternative: Monokai
Set Theme "Nord"        # Alternative: Nord
Set Theme "Tokyo Night" # Alternative: Tokyo Night
```

## Themes Available

VHS supports many built-in themes:
- `Dracula` (default in our tape)
- `Monokai`
- `Nord`
- `Tokyo Night`
- `Catppuccin`
- `Gruvbox`
- Or provide a custom JSON theme file

## Regenerating After Updates

When installation steps change:

1. Edit `install-walkthrough.tape`
2. Run `vhs install-walkthrough.tape`
3. Optimize: `gifsicle -O3 --colors 256 install-walkthrough.gif -o install-walkthrough-optimized.gif`
4. Replace the old GIF in blog post
5. Commit both the tape file and new GIF

## Benefits of VHS

✅ **Consistent output** - Same recording every time
✅ **Version control** - Tape files tracked in git
✅ **Easy updates** - Edit tape file, regenerate GIF
✅ **Lightweight** - No video recording software needed
✅ **Customizable** - Adjust speed, colors, size via commands
✅ **Reproducible** - Anyone can regenerate the exact same GIF

## References

- [VHS GitHub](https://github.com/charmbracelet/vhs)
- [VHS Documentation](https://github.com/charmbracelet/vhs/tree/main/examples)
- [Charm Bracelet](https://charm.sh/)

## Alternative: Screen Recording

If VHS doesn't work for your setup, consider:
- **Kap** (macOS) - Screen recorder with GIF export
- **Peek** (Linux) - Simple animated GIF screen recorder
- **ScreenToGif** (Windows) - Record and edit GIFs

But VHS is recommended for consistency and maintainability.
