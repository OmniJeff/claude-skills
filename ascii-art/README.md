# ascii-art

A Claude Code skill that generates ASCII art for software projects — text banners, decorative borders, icons, and logos with full theme support.

## Install

```bash
# Clone the repo
git clone https://github.com/OmniJeff/claude-skills

# Symlink the skill into your Claude Code skills directory
mkdir -p ~/.claude/skills
ln -s /path/to/claude-skills/ascii-art ~/.claude/skills/ascii-art
```

## Usage

### Text banners
```
/ascii-art banner "My App"
/ascii-art banner "DANGER" --theme cyberpunk --font bold
```

### Bordered boxes
```
/ascii-art box "Section Title"
/ascii-art box "TODO: Fix before release" --theme l33t
```

### Icons & characters
```
/ascii-art icon cat
/ascii-art icon robot
/ascii-art icon skull
```

### Dividers
```
/ascii-art divider
/ascii-art divider --theme retro
```

### Browse the library
```
/ascii-art list
/ascii-art list characters
/ascii-art list symbols
```

### Natural language
```
/ascii-art make a spooky banner that says "DANGER ZONE" with skulls on each side
/ascii-art create a retro header for my CLI tool called "DataCruncher"
```

### Insert into code files
```
/ascii-art banner "My App" --output inline --file src/main.py --at-line 1
/ascii-art divider --output inline --file app.js --before "function main"
```

Comment wrapping is auto-detected from the file extension.

### Write to standalone files
```
/ascii-art banner "Project Name" --output file --file banner.txt
```

## Themes

Set a project default by adding `.ascii-art.yaml` to your project root:

```yaml
theme: cyberpunk
```

Or override per invocation with `--theme`:

| Theme | Vibe |
|-------|------|
| `minimal` | Clean, modern, understated (default) |
| `retro` | Green CRT, dot-matrix, BBS |
| `corporate` | 80s business, blue/gray, conservative |
| `cyberpunk` | Neon, glitch, angular |
| `l33t` | Hacker culture, NFO files, IRC |
| `playful` | Bright, fun, cartoon energy |

Themes control font selection, border style, color palette, and art generation style.

## Art Library

Ships with 26 pre-made pieces across three categories:

**Dividers** — simple-line, double-line, wave, zigzag, dots, stars, hash-block, arrows

**Symbols** — arrow-right, arrow-left, checkmark, warning, star, skull, lightning, heart, gear, lock

**Characters** — cat, dog, robot, wizard, shrug, crab, ghost, rocket

Plus on-the-fly generation for anything not in the library.

## Features

- Hybrid text engine: uses `figlet`/`toilet` if installed, Claude-generated fallback if not
- ASCII only borders (no Unicode) for maximum compatibility
- ANSI colors in terminal, auto-stripped for file output
- Configurable width (default 80 columns)
- Always previews before writing to files
- Claude can use it proactively when scaffolding projects

## License

MIT
