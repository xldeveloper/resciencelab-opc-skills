# VHS Tape File: OPC Skills Installation in Claude Code
# Generates animated GIF walkthrough for blog post
# Run: vhs install-walkthrough.tape

Output install-walkthrough.gif

# Terminal settings
Set Shell bash
Set FontSize 24
Set Width 1400
Set Height 800
Set Padding 20
Set Theme "Dracula"
Set PlaybackSpeed 1.0
Set TypingSpeed 100ms

# Clear screen
Hide
Type "clear"
Enter
Show

# Introduction frame
Type "# OPC Skills Installation in Claude Code"
Sleep 1s
Enter
Enter
Type "# Step 1: Add OPC Skills Marketplace"
Sleep 500ms
Enter

# Command 1: Add marketplace
Type "/plugin marketplace add ReScienceLab/opc-skills"
Sleep 800ms
Enter
Sleep 1.5s

# Success message (simulated)
Type "✓ Marketplace 'opc-skills' added successfully"
Sleep 1.5s
Enter
Enter

# Command 2: List available skills
Type "# Step 2: View Available Skills"
Sleep 500ms
Enter
Type "/plugin marketplace list opc-skills"
Sleep 800ms
Enter
Sleep 1s

# Simulated output
Type "Available skills from opc-skills:"
Sleep 300ms
Enter
Type "  • reddit - Reddit research (no API key)"
Sleep 200ms
Enter
Type "  • twitter - Twitter/X research"
Sleep 200ms
Enter
Type "  • domain-hunter - Domain research"
Sleep 200ms
Enter
Type "  • seo-geo - SEO & GEO optimization"
Sleep 200ms
Enter
Type "  • requesthunt - Product validation"
Sleep 200ms
Enter
Type "  • logo-creator - AI logo generation"
Sleep 200ms
Enter
Type "  • banner-creator - Social banners"
Sleep 200ms
Enter
Type "  • nanobanana - Gemini image gen"
Sleep 200ms
Enter
Type "  • producthunt - Product Hunt research"
Sleep 1.5s
Enter
Enter

# Command 3: Install a skill
Type "# Step 3: Install a Skill"
Sleep 500ms
Enter
Type "/plugin install reddit@opc-skills"
Sleep 800ms
Enter
Sleep 1.5s

# Success message
Type "✓ Plugin 'reddit@opc-skills' installed successfully"
Sleep 1.5s
Enter
Enter

# Command 4: Verify installation
Type "# Step 4: Verify Installation"
Sleep 500ms
Enter
Type "/plugin list"
Sleep 800ms
Enter
Sleep 1s

# List installed
Type "Installed plugins:"
Sleep 300ms
Enter
Type "  ✓ reddit@opc-skills (v1.0.0)"
Sleep 1.5s
Enter
Enter

# Final message
Type "# Installation Complete! 🎉"
Sleep 2s
Enter
Type "# Try: 'Search r/programming for AI coding tools'"
Sleep 3s

# End recording
Sleep 1s
