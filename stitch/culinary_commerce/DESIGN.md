---
name: Culinary Commerce
colors:
  surface: '#fff8f4'
  surface-dim: '#e0d9d3'
  surface-bright: '#fff8f4'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#faf2ed'
  surface-container: '#f4ece7'
  surface-container-high: '#eee7e1'
  surface-container-highest: '#e9e1dc'
  on-surface: '#1e1b18'
  on-surface-variant: '#5a4138'
  inverse-surface: '#33302c'
  inverse-on-surface: '#f7efea'
  outline: '#8f7066'
  outline-variant: '#e3bfb2'
  surface-tint: '#a83900'
  primary: '#a43700'
  on-primary: '#ffffff'
  primary-container: '#cd4700'
  on-primary-container: '#fffbff'
  inverse-primary: '#ffb59a'
  secondary: '#1b6d24'
  on-secondary: '#ffffff'
  secondary-container: '#a0f399'
  on-secondary-container: '#217128'
  tertiary: '#805200'
  on-tertiary: '#ffffff'
  tertiary-container: '#a16800'
  on-tertiary-container: '#fffbff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffdbcf'
  primary-fixed-dim: '#ffb59a'
  on-primary-fixed: '#380d00'
  on-primary-fixed-variant: '#802a00'
  secondary-fixed: '#a3f69c'
  secondary-fixed-dim: '#88d982'
  on-secondary-fixed: '#002204'
  on-secondary-fixed-variant: '#005312'
  tertiary-fixed: '#ffddb5'
  tertiary-fixed-dim: '#ffb957'
  on-tertiary-fixed: '#2a1800'
  on-tertiary-fixed-variant: '#643f00'
  background: '#fff8f4'
  on-background: '#1e1b18'
  surface-variant: '#e9e1dc'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  display-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 32px
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 22px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  numeric-total:
    fontFamily: Inter
    fontSize: 30px
    fontWeight: '700'
    lineHeight: 36px
  numeric-price:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 20px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 18px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
  label-sm:
    fontFamily: Inter
    fontSize: 10px
    fontWeight: '700'
    lineHeight: 12px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-sm: 0.75rem
  gutter-lg: 1.5rem
  margin: 1.25rem
  margin-mobile: 0.75rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

This design system is engineered specifically for fast-paced, high-volume Food & Beverage hospitality environments. It balances functional ergonomics—tailored for grease, speed, and continuous touch input—with a warm, tactile, and appetizing culinary personality.

### Aesthetic Tone
- **Warm Culinary Minimalism:** Replaces sterile, cold enterprise interfaces with an organic palette of warm alabaster, sun-ripened terracotta, and fresh kitchen herb greens.
- **Physical Touch Ergonomics:** Interfaces simulate physical kitchen order pads and prep tickets with clean, structural separations and crisp, tactile button definitions.
- **Uncompromised Contrast:** Critical information such as order modifications, table numbers, seat assignments, and prices must remain instantly readable from wide angles under harsh kitchen fluorescent strips or dim dining room ambient lighting.

### Target Audience & Core Experience
- **Primary Users:** Line cashiers, waitstaff, bartenders, and expo expeditors operating tablet terminals (predominantly landscape) and dedicated desktop register touchscreens.
- **Emotional Response:** Reassuring, rapid, error-proof, and inviting. The interface must never feel intimidating during a chaotic dinner rush; it projects absolute reliability and culinary delight.

## Colors

The color palette grounds digital utility in culinary warmth. Color serves as a functional signifier for operational urgency, status verification, and item grouping.

### Palette Architecture
- **Canvas Base (`#FAF7F2`):** Warm Cream / Alabaster. Serves as the eye-relaxing backdrop that reduces eye strain during 10-hour shifts while keeping the interface feeling natural and clean.
- **Surface Elevation (`#FFFFFF`):** Pure White. Reserved for active interactive cards, item selection tiles, modal dialogs, and receipt panels to create crisp optical contrast against the canvas.
- **Primary Brand / Action (`#E65100`):** Appetizing Terracotta. Used for primary CTAs ("Pay Now", "Send to Kitchen", "Charge"), active navigation indicators, and primary modifier badges.
- **Secondary / Success (`#2E7D32`):** Fresh Herb Green. Assigned to completed payments, confirmed orders, active table statuses, and positive tally modifiers.
- **Warning / Hold (`#F9A825`):** Warm Amber. Designates held orders, kitchen delay warnings, split-bill flags, and low inventory badges.
- **Destructive / Void (`#D32F2F`):** Chili Red. Used strictly for line item deletion, void order approvals, urgent 86'd notifications, and payment declines.
- **Borders & Dividers (`#EFEBE4`):** Soft Warm Biscuit. Outlines structural modules, card boundaries, and list separations without heavy visual clutter.
- **Text Primary (`#1E1B18`):** Deep Espresso Charcoal. Ensures maximum readability without the optical harshness of pure `#000000`.
- **Text Secondary (`#756E68`):** Muted Warm Grey. Applied to timestamps, modifier descriptions, table seat tags, and receipt metadata.

## Typography

The typographic hierarchy pairs the welcoming, modern geometry of **Plus Jakarta Sans** for menu items, section titles, and modal headers with the disciplined, highly legible structure of **Inter** for data tables, modifier lists, body copy, and receipt tickets.

### Tabular Numbers & Alignment
- All numerical values (`numeric-total`, `numeric-price`, quantities, tax percentages, and seat numbers) must use monospace numbers via CSS `font-variant-numeric: tabular-nums` (or `tnum`).
- Currency symbols align systematically with price values to prevent optical jitter when items are incremented or decremented in rapid succession.
- Product item headings are limited to 2 lines max before truncating with an ellipsis to maintain grid symmetry across menu matrixes.

## Layout & Spacing

Designed fundamentally for landscape orientation (tablets 10" and above, plus 15" to 22" desktop point-of-sale touch displays). 

### Layout Model
- **Primary Layout Partition:** Three distinct horizontal functional columns:
  1. **Navigation Rail (Left):** 80px fixed width, vertical stack of master functions.
  2. **Product Catalog & Category Matrix (Center Workspace):** Fluid dynamic grid occupying 55%–65% of viewport width. Accommodates high-speed item discovery and search.
  3. **Order Ticket & Checkout Panel (Right Sidebar):** 360px–420px fixed panel dedicated to active cart lines, modifiers, subtotal math, and instant tender actions.
- **Touch Target Imperative:** Every clickable or tappable interactive surface adheres strictly to a **minimum 48×48px physical hit area** to eliminate fat-finger errors during high-speed checkout sequences.

### Form Factor Adaptations
- **Desktop POS (1920×1080 / 1440×900):** Center workspace implements a 4 to 5-column product tile grid with 16px (`gutter`) spacing. Cart drawer remains permanently pinned open on the right.
- **Tablet Landscape (1024×768 to 1280×800):** Center workspace compresses to a 3-column product tile grid with 12px (`gutter-sm`) spacing. Order panel stays fixed at 360px.
- **Tablet Portrait (Emergency / Mobile Floor Terminal):** Navigation rail collapses into an expandable hamburger or bottom bar; active ticket shifts to a bottom-anchored peek sheet that expands upwards upon swipe or tap.

## Elevation & Depth

Visual hierarchy uses warm, physical, and ambient layering rather than generic digital drop shadows. 

### Surface Tiers & Depth Strategy
- **Layer 0 (Canvas Base):** Warm Cream (`#FAF7F2`). Non-elevated substrate.
- **Layer 1 (Card & Tile Surfaces):** Pure White (`#FFFFFF`) with a 1px structural stroke of `#EFEBE4`. Soft warm shadow: `0 2px 8px rgba(30, 27, 24, 0.04)`.
- **Layer 2 (Hover & Active Product Tiles / Floating Panels):** White (`#FFFFFF`) with `0 4px 16px rgba(30, 27, 24, 0.06)`, simulating gentle lift when pressed.
- **Layer 3 (Modals, Customizer Sheets & Numeric Numpads):** Floating White (`#FFFFFF`) overlay surfaces with a warm diffused shadow: `0 12px 32px rgba(30, 27, 24, 0.12)`, backed by a 40% translucent warm scrim (`rgba(30, 27, 24, 0.4)`).
- **Physical Inset (Tally & Bill Wells):** Active ticket lists and input wells use a neutral inset wash (`#F5F1E9`) to create clear sunken containment for transient numerical data.

## Shapes

The shape system employs deliberate, role-based curvature that balances organic warmth with structural space efficiency:

- **Cards, Modals & Item Containers:** 12px (`rounded-lg`) border-radius. Delivers a soft, modern silhouette that looks appetizing and non-industrial without sacrificing internal grid padding.
- **Interactive Controls (Buttons, Inputs, Steppers):** 8px (`rounded-md`) border-radius. Provides unmistakable button affordance with compact boundaries that optimize physical touch density.
- **Filters, Category Tabs & Status Badges:** 999px (full pill). Creates clear differentiation between actionable category switches/status chips and product cards.

## Components

### 1. Navigation Rail
- **Dimensions:** Fixed 80px width, 100vh height. Background: `#FAF7F2` with a 1px solid right border of `#EFEBE4`.
- **Items:** 64×64px interactive slot centered inside the 80px track. Contains a 24px icon and a 10px uppercase label (`label-sm`).
- **Active State:** Terracotta (`#E65100`) icon and label, backed by a soft Terracotta tint (`rgba(230, 81, 0, 0.08)`) with an 8px border-radius and a vertical 4px left-edge indicator bar.

### 2. Product Menu Tiles
- **Structure:** 1:1 or 4:3 aspect ratio card. Pure White background (`#FFFFFF`), 12px radius, 1px border (`#EFEBE4`).
- **Visuals:** Top image or color-coded category flag, bottom item name (`headline-sm`), price (`numeric-price`), and optional badge (e.g., "Out of Stock" in Chili Red or "Popular" in Warm Amber).
- **Press State:** Instant physical depression: 2px scale down (`transform: scale(0.98)`) and border color shift to `#E65100`.

### 3. Category Filter Tabs
- **Style:** Pill shape (999px border-radius), minimum height 44px, horizontal scrolling bar.
- **Default State:** Transparent or pure white background with 1px border `#EFEBE4`, text `#756E68`.
- **Selected State:** Solid Primary Terracotta (`#E65100`) fill, text pure white (`#FFFFFF`), subtle glow shadow.

### 4. Order Ticket & Line Items
- **Container:** Pure White right column with left border `#EFEBE4`.
- **Line Items:** Minimum height 56px per row. 
  - Left: Quantity pill counter (stepper buttons `+` and `-` sized at 32×32px).
  - Middle: Dish name (`label-lg`) with nested indented modifiers in `#756E68` (`body-sm`).
  - Right: Line item subtotal in tabular numbers (`numeric-price`).
- **Swipe / Delete Action:** Swipe left on touch displays reveals Chili Red (`#D32F2F`) void button; or a dedicated trash icon visible in item editor mode.

### 5. Buttons & Primary Actions
- **Pay / Tender Action:** Full width of ticket column, minimum 56px height, 8px radius. Solid Terracotta (`#E65100`) background, bold white text (`display-md` or `headline-lg`), displaying "Pay $XX.XX".
- **Secondary Actions (Hold, Split, Discount):** 48px height, 8px radius, white surface with `#EFEBE4` border, text `#1E1B18`.
- **Void / Clear Cart:** 48px height, ghost or light red background (`rgba(211, 47, 47, 0.08)`), text `#D32F2F`.

### 6. Modifier & Customization Modal
- **Format:** Centered modal or slide-up bottom sheet with 12px radius.
- **Modifier Groups:** Single-select (radio pills) or multi-select (checkbox chips). Clear display of price deltas (e.g., "+$1.50 Oat Milk").
- **Quantity Selector:** Prominent 48×48px stepper keys with tabular counter in the center.

### 7. Input Fields & On-Screen Numpad
- **Inputs:** 48px height, 8px radius, 1px border `#EFEBE4`, background `#FFFFFF`. Active focus state triggers 2px ring in `#E65100`.
- **Touch Numpad (Tender & Custom Amount):** Grid of large 64×64px keys with 8px radius, pure white keys over `#FAF7F2` container. Number glyphs set in `display-md` (Inter, bold tabular nums).