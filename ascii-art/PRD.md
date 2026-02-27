# ASCII Art Skill — Product Requirements Document

**Version:** 1.0
**Date:** 2026-02-27
**Status:** Draft

---

## 1. Overview

A Claude Code skill that generates and manages ASCII art for software projects. The skill supports text banners, decorative borders/boxes, and pictorial icons/logos. It can be invoked explicitly by the user or used proactively by Claude when contextually appropriate (e.g., scaffolding a new project, adding section headers).

---

## 2. Art Types

The skill produces three categories of ASCII art:

### 2.1 Text Banners
Large stylized text rendered using figlet-style fonts. Used for file headers, project names, section titles, etc.

### 2.2 Decorative Borders & Boxes
Framed text using ASCII box-drawing characters. Used for section dividers, highlighted comments, warning blocks, or title cards.

### 2.3 Logos & Icons
Small pictorial ASCII art — animals, objects, symbols, characters. Used for personality, branding, or decoration.

---

## 3. Output Modes

The skill supports three output modes, selected via arguments at invocation:

| Mode | Argument | Behavior |
|------|----------|----------|
| **Terminal** | `--output terminal` (default) | Prints art to stdout for the user to view/copy |
| **Inline in file** | `--output inline --file <path>` | Inserts art into an existing source file at a specified position |
| **Standalone file** | `--output file --file <path>` | Writes art to a new or existing standalone text file |

### 3.1 Preview Requirement
All output modes MUST preview the generated art in the terminal and receive user confirmation before writing to any file. Terminal-only output displays immediately with no confirmation step.

### 3.2 Insert Position (Inline Mode)
When inserting into an existing file, the user specifies where:
- `--at-line <n>` — insert at a specific line number
- `--before "<pattern>"` — insert before the first line matching a pattern
- `--after "<pattern>"` — insert after the first line matching a pattern

If no position is specified, the skill should ask the user.

---

## 4. Text Rendering Engine

### 4.1 Hybrid Approach
The skill uses a hybrid text rendering strategy:

1. **Primary:** Shell out to `figlet` or `toilet` if installed on the system
2. **Fallback:** Claude generates the ASCII text art directly if neither tool is available

### 4.2 Curated Font Set
Rather than exposing the full figlet font catalog, the skill offers 3–5 named styles:

| Style Name | Description | Figlet Font (when available) |
|------------|-------------|------------------------------|
| `bold` | Heavy, attention-grabbing block letters | ANSI Shadow |
| `slim` | Narrow, space-efficient lettering | Slant |
| `retro` | Vintage terminal aesthetic | Banner3 |
| `block` | Solid, squared-off characters | Block |
| `mini` | Compact, minimal footprint | Small |

The default style is `bold` unless overridden by the active theme or `--font` argument.

When Claude generates text art as a fallback (no figlet/toilet), it should approximate the aesthetic of the named style as closely as possible.

---

## 5. Border & Box Style

**ASCII only.** All borders and boxes use plain ASCII characters for maximum compatibility:

```
+---------------------------+
|  Section Title            |
+---------------------------+

===========================
  Section Title
===========================

/****************************
 *  Section Title           *
 ****************************/
```

No Unicode box-drawing characters (`┌─┐│└─┘`). This ensures art renders correctly in any terminal, editor, font, diff viewer, or CI log.

---

## 6. Comment Wrapping

When inserting art inline into code files, the skill auto-detects the file's language from its extension and wraps the art in the appropriate comment syntax:

| Extension | Comment Style |
|-----------|---------------|
| `.py`, `.rb`, `.sh`, `.yaml` | `#` line comments |
| `.js`, `.ts`, `.go`, `.rs`, `.java`, `.c`, `.cpp` | `//` line comments or `/* */` blocks |
| `.css`, `.html` | `/* */` or `<!-- -->` |
| `.sql` | `--` line comments |
| `.lua` | `--` line comments |

If the extension is unrecognized, the skill should ask the user for the comment style.

---

## 7. Pre-Made Art Library

### 7.1 Storage Format
- Each art piece is a standalone `.txt` file in an `art/` directory within the skill
- An `art/catalog.yaml` index file maps each piece to metadata: name, category, tags, description, suggested themes

### 7.2 Directory Structure
```
ascii-art/
  art/
    catalog.yaml
    dividers/
      simple-line.txt
      double-line.txt
      wave.txt
      zigzag.txt
      dots.txt
    symbols/
      arrow-right.txt
      checkmark.txt
      warning.txt
      star.txt
      skull.txt
      lightning.txt
    characters/
      cat.txt
      dog.txt
      robot.txt
      wizard.txt
      shrug.txt
      crab.txt
  ...
```

### 7.3 Starter Categories

**Dividers & Separators** — horizontal rules, section breaks, decorative line dividers

**Common Symbols & Icons** — arrows, checkmarks, warning signs, stars, skulls, lightning bolts, etc.

**Animals & Characters** — cats, dogs, robots, wizards, shrugging person, etc.

### 7.4 On-the-Fly Generation
In addition to the library, Claude can generate custom ASCII art on demand based on freeform descriptions. Library art is used when a known piece is requested; otherwise Claude generates it fresh.

---

## 8. Color Support

The skill uses ANSI color codes for terminal output by default:
- Colors enhance banners, icons, and borders in the terminal
- Color codes are **automatically stripped** when writing to files (inline or standalone), since files should contain only plain text
- Color palette is controlled by the active theme (see Section 10)

---

## 9. Width Management

- **Default width:** 80 columns
- **Override:** `--width <n>` argument to specify a different maximum width
- All generated art respects the width constraint — text wraps or truncates, banners scale down, boxes resize
- The width setting applies to all output modes uniformly

---

## 10. Theme System

Themes control the overall aesthetic of generated art. A theme defines:

| Property | Description |
|----------|-------------|
| `tone` | The vibe/aesthetic (e.g., "retro computing," "80s corporate," "cyberpunk neon") |
| `default_font` | Which figlet font style to use by default |
| `border_style` | Preferred border character patterns |
| `color_palette` | ANSI color set for terminal output |
| `art_preferences` | Which library art pieces and generation styles fit the theme |

### 10.1 Built-In Themes

| Theme | Tone | Description |
|-------|------|-------------|
| `retro` | Vintage computing | Green-on-black CRT aesthetic, dot-matrix feel, old-school BBS vibes |
| `corporate` | 80s business | Clean, conservative, Helvetica energy, blue/gray palette |
| `cyberpunk` | Futuristic dystopia | Neon colors, glitch effects, angular aggressive shapes |
| `l33t` | Hacker culture | Substituted characters, edgy symbols, dark palette |
| `minimal` | Clean & modern | Thin lines, lots of whitespace, monochrome, understated |
| `playful` | Fun & casual | Bright colors, friendly shapes, humor encouraged |

### 10.2 Project Configuration
A `.ascii-art.yaml` file in the project root sets the default theme and other project-level settings:

```yaml
theme: cyberpunk
default_width: 100
```

Settings in this file apply to all invocations within the project unless overridden by CLI arguments (e.g., `--theme retro` on a single invocation).

### 10.3 Override Precedence
From lowest to highest priority:
1. Skill defaults (theme: `minimal`, width: `80`)
2. `.ascii-art.yaml` project config
3. CLI arguments (`--theme`, `--width`, `--font`, etc.)

---

## 11. Invocation

### 11.1 Skill Name
`/ascii-art`

### 11.2 Subcommands

| Subcommand | Usage | Description |
|------------|-------|-------------|
| `banner` | `/ascii-art banner "Hello World"` | Generate a text banner |
| `box` | `/ascii-art box "Section Title"` | Generate a bordered box |
| `icon` | `/ascii-art icon cat` | Retrieve or generate a pictorial icon |
| `divider` | `/ascii-art divider` | Generate a section divider |
| `list` | `/ascii-art list [category]` | List available pre-made art |
| `themes` | `/ascii-art themes` | List available themes |

### 11.3 Natural Language
The skill also accepts freeform descriptions:

```
/ascii-art make me a spooky banner that says "DANGER ZONE" with skulls on each side
/ascii-art create a box around "TODO: Fix this before release" styled like a warning
/ascii-art give me a robot icon for my CLI tool's startup message
```

Claude interprets the intent and routes to the appropriate generation approach.

### 11.4 Common Arguments

| Argument | Short | Description |
|----------|-------|-------------|
| `--output <mode>` | `-o` | Output mode: `terminal`, `inline`, `file` |
| `--file <path>` | `-f` | Target file for `inline` or `file` output |
| `--at-line <n>` | | Insert position: line number |
| `--before "<pattern>"` | | Insert position: before matching line |
| `--after "<pattern>"` | | Insert position: after matching line |
| `--theme <name>` | `-t` | Override the project theme |
| `--font <style>` | | Override the font style |
| `--width <n>` | `-w` | Override the max width |

---

## 12. Proactive Usage

Claude Code may use this skill proactively — without explicit `/ascii-art` invocation — when contextually appropriate. Examples:

- Adding a file header banner when creating a new source file
- Inserting a section divider when scaffolding a large file
- Adding a project logo banner to a new README or entry point
- Decorating warning comments or TODO blocks

Proactive usage should:
- Respect the project's theme configuration
- Always preview before writing (same as explicit invocation)
- Be tasteful — enhance readability, not clutter code

---

## 13. Future Considerations (v2)

The following features are out of scope for v1 but noted for future development:

- **Image-to-ASCII conversion** — Accept an image file and convert it to ASCII art using a tool like `jp2a`
- **Custom themes** — Allow users to define their own themes in the config file or a `themes/` directory, extending or overriding built-in themes
- **Animation** — Frame-by-frame ASCII animations for terminal output
- **Responsive art** — Art that auto-adapts to the current terminal width rather than a fixed setting

---

## 14. Technical Architecture

### 14.1 Skill Structure
```
ascii-art/
  .claude-plugin/
    plugin.json         # Plugin manifest
  skills/
    ascii-art/
      SKILL.md          # Main skill prompt
  art/
    catalog.yaml        # Art index with metadata
    dividers/           # Divider art .txt files
    symbols/            # Symbol/icon art .txt files
    characters/         # Character art .txt files
  themes/
    retro.yaml
    corporate.yaml
    cyberpunk.yaml
    l33t.yaml
    minimal.yaml
    playful.yaml
  .ascii-art.yaml       # Example project config (template)
  PRD.md                # This document
```

### 14.2 Dependencies
- **Required:** None (Claude-generated fallback works with zero dependencies)
- **Optional:** `figlet` or `toilet` CLI tools for higher-quality text banners

### 14.3 Language Comment Detection
The skill maintains an internal mapping of file extensions to comment syntax. This is embedded in the skill prompt, not an external config.

---

## 15. Acceptance Criteria

- [ ] `/ascii-art banner "text"` generates a styled text banner using figlet (if available) or Claude fallback
- [ ] `/ascii-art box "text"` generates an ASCII-bordered box
- [ ] `/ascii-art icon <name>` retrieves art from the library or generates it
- [ ] `/ascii-art divider` generates a section divider
- [ ] `/ascii-art list` shows available library art
- [ ] `--output inline --file <path>` inserts art into a code file with correct comment wrapping
- [ ] `--output file --file <path>` writes art to a standalone file
- [ ] Preview is always shown before file writes
- [ ] `.ascii-art.yaml` project config is respected
- [ ] `--theme` override works per-invocation
- [ ] All six built-in themes produce visually distinct output
- [ ] Art respects the configured width (default 80)
- [ ] ANSI colors render in terminal, are stripped for file output
- [ ] Natural language descriptions produce appropriate art
- [ ] Claude proactively uses the skill when scaffolding or decorating code
