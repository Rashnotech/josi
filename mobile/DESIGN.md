---
name: Josi Ride Light
colors:
  surface: '#f7f9fb'
  surface-dim: '#d8dadc'
  surface-bright: '#f7f9fb'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f6'
  surface-container: '#eceef0'
  surface-container-high: '#e6e8ea'
  surface-container-highest: '#e0e3e5'
  on-surface: '#191c1e'
  on-surface-variant: '#5d3f3e'
  inverse-surface: '#2d3133'
  inverse-on-surface: '#eff1f3'
  outline: '#916e6d'
  outline-variant: '#e6bdbb'
  surface-tint: '#bf0029'
  primary: '#b90027'
  on-primary: '#ffffff'
  primary-container: '#e31837'
  on-primary-container: '#fffaf9'
  inverse-primary: '#ffb3b1'
  secondary: '#5f5e5f'
  on-secondary: '#ffffff'
  secondary-container: '#e2dfe0'
  on-secondary-container: '#636263'
  tertiary: '#4d5c72'
  on-tertiary: '#ffffff'
  tertiary-container: '#65758c'
  on-tertiary-container: '#fcfbff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffdad8'
  primary-fixed-dim: '#ffb3b1'
  on-primary-fixed: '#410007'
  on-primary-fixed-variant: '#92001d'
  secondary-fixed: '#e5e2e3'
  secondary-fixed-dim: '#c8c6c7'
  on-secondary-fixed: '#1b1b1c'
  on-secondary-fixed-variant: '#474647'
  tertiary-fixed: '#d3e4fe'
  tertiary-fixed-dim: '#b7c8e1'
  on-tertiary-fixed: '#0b1c30'
  on-tertiary-fixed-variant: '#38485d'
  background: '#f7f9fb'
  on-background: '#191c1e'
  surface-variant: '#e0e3e5'
typography:
  headline-xl:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: '800'
    lineHeight: '1.1'
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: '1.2'
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: '1.2'
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: '1.3'
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: '1.6'
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.5'
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: '1'
    letterSpacing: 0.05em
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: '1'
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 40px
  gutter: 16px
  margin-mobile: 16px
  margin-desktop: 32px
---

## Brand & Style
This design system transitions from a dark, cinematic aesthetic to a high-energy, high-clarity light mode. The brand personality is kinetic, precise, and authoritative, targeting a fast-paced audience that demands immediate information legibility. 

The style is **Corporate Modern with a High-Contrast edge**. It utilizes a "White Space" philosophy where the absence of color creates the canvas for the primary brand red to act as a high-velocity signal. The interface is characterized by razor-sharp clarity, utilizing subtle tonal layering to replace the deep shadows of its predecessor, ensuring the UI feels light, airy, and exceptionally fast.

## Colors
The palette is anchored by a pure white background to maximize luminosity and perceived speed. 

- **Primary (#E31837):** A vibrant, aggressive red used exclusively for primary actions, critical alerts, and active states.
- **Secondary (#1A1A1B):** An "Off-Black" used for primary text and iconography to ensure peak contrast against the white base.
- **Neutral/Surface (#F8FAFC):** A cool, subtle grey used for containers, input backgrounds, and secondary surfaces to provide structure without adding visual weight.
- **Success/Warning/Error:** Standard utility colors should be adjusted for high-saturation light mode visibility (e.g., Success #10B981).

## Typography
The system relies on **Inter** to maintain a systematic, utilitarian feel. High contrast is the priority; headlines use ExtraBold and Bold weights with tight letter-spacing to command attention.

- **Scale:** A tight modular scale ensures that information density remains high.
- **Contrast:** Body text never drops below #1A1A1B to ensure WCAG AAA compliance on the #FFFFFF background.
- **Labels:** Small labels utilize increased letter-spacing and uppercase styling to provide a technical, "instrument-panel" feel.

## Layout & Spacing
The layout follows a **Fluid Grid** model based on an 8px rhythm. 

- **Desktop:** 12-column grid with 24px gutters. Margins are generous (32px+) to allow the white background to act as a structural element.
- **Mobile:** 4-column grid with 16px gutters and 16px margins.
- **Density:** Elements are spaced to allow for "breathable density"—information is packed tightly within components, but components are separated by generous whitespace.

## Elevation & Depth
In this light-mode iteration, depth is conveyed through **Tonal Layers** and **Low-Contrast Outlines** rather than heavy shadows.

- **Level 0 (Base):** #FFFFFF (Pure White).
- **Level 1 (Cards/Surface):** #F8FAFC (Cool Grey) or a 1px border of #E2E8F0.
- **Level 2 (Dropdowns/Modals):** #FFFFFF with a very soft, diffused shadow (0px 10px 15px -3px rgba(0, 0, 0, 0.05)).
- **Level 3 (Popovers):** #FFFFFF with a defined border and elevated shadow.
- **Interaction:** Hover states should transition the background from White to #F1F5F9 rather than lifting the element.

## Shapes
The shape language is **Soft (0.25rem)**. This maintains a professional, structured appearance while subtly removing the harshness of sharp corners.

- **Standard Elements:** 4px radius for buttons and input fields.
- **Containers:** 8px (rounded-lg) for cards and modals to distinguish them from the page structure.
- **Iconography:** Use "Sharp" or "Minimal Round" icon sets to match the precision of the Inter typeface.

## Components
- **Buttons:** Primary buttons use #E31837 with white text. Secondary buttons use a #1A1A1B outline or solid neutral-200 background. Focus states must use a 2px offset ring in the primary red.
- **Inputs:** Use #F8FAFC as the fill color with a 1px bottom-border only or a full-stroke in #E2E8F0. On focus, the border color shifts to #1A1A1B.
- **Chips:** Small, rectangular shapes with 4px radius. Use light grey backgrounds with dark text for inactive states, and Primary Red for active states.
- **Lists:** Clean dividers using #F1F5F9. High-density padding (12px vertical) to maximize information visibility.
- **Cards:** No shadow by default; 1px border in #E2E8F0. On hover, a subtle elevation change or a Primary Red accent bar on the left edge can be applied.
- **Data Tables:** High-contrast headers (#1A1A1B) with thin, subtle row separators. Alternating row colors are not used; whitespace is the primary separator.